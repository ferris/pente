import java.util.concurrent.Callable;
import java.util.concurrent.Executors;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;

public class GameAI {
  private static final float EXPLORATION_PARAMETER = 1;
  private int calculationTime;
  private ExecutorService executorService;
  private int availableProcessors;

  public GameAI(int calculationTime) {
    this.calculationTime = calculationTime;
    availableProcessors = Runtime.getRuntime().availableProcessors();
    executorService = Executors.newFixedThreadPool(availableProcessors);
  }
  
  public int[] getComputerMove(GameState currentGameState) {
    int beginTime = millis();
    // create tree
    MCTNode root = new MCTNode(currentGameState);
    MCTSSolverTask.treeRoot = root;
    MCTSSolverTask.parentAI = this;
    // analyze within time
    while (millis() - beginTime < calculationTime) {
      float turnValue = ParallelMCTSSolver(root);
      // stop (break) to return if proven win or loss
      if (turnValue == Float.POSITIVE_INFINITY || turnValue == Float.NEGATIVE_INFINITY) {
        break;
      }
    }
    // return the move from the best child's GameState
    return secureChild(root, 1).getGameState().getPreviousMove();
  }

  private float ParallelMCTSSolver(MCTNode rootNode) {
    if (rootNode.isLeaf()) {
      expand(rootNode);
    }
    MCTNode[] bestChildren = selectFew(rootNode, EXPLORATION_PARAMETER, availableProcessors);
    ArrayList<MCTSSolverTask> tasks = new ArrayList<MCTSSolverTask>();
    for (MCTNode child : bestChildren) {
      rootNode.addOneToVisits();
      if (child.getTotalValue() == Float.POSITIVE_INFINITY) {
        rootNode.setValue(Float.NEGATIVE_INFINITY);
        return Float.POSITIVE_INFINITY;
      }
      tasks.add(new MCTSSolverTask(child));
    }
    if (tasks.size() == 0) {
      for (MCTNode child : rootNode.getChildren()) {
        if (child.getTotalValue() != Float.NEGATIVE_INFINITY) {
          rootNode.addToValue(-1 * availableProcessors);
          return -1;
        }
      }
    }
    // analyze all results
    List<Future<Float>> results;
    float sumOfResults = 0;
    try {
      results = executorService.invokeAll(tasks);
      for (Future<Float> futureResult : results) {
        Float result = futureResult.get();
        if (result != Float.POSITIVE_INFINITY && result != Float.NEGATIVE_INFINITY) {
          sumOfResults += result;
        }
      }
    } catch (Exception e) {
      println(e);
    }
    rootNode.addToValue(sumOfResults);
    return sumOfResults;
  }

  private float MCTSSolver(MCTNode n) {
    if (n.getGameState().getWinner() == (3 - n.getGameState().getPlayerOfCurrentTurn())) {
      n.setValue(Float.POSITIVE_INFINITY);
      return Float.NEGATIVE_INFINITY;
    }
    MCTNode bestChild;
    float result;
    if (n.isLeaf()) {
      bestChild = expand(n);
    } else {
      bestChild = select(n, EXPLORATION_PARAMETER);
    }
    n.addOneToVisits();
    float bestChildVal = bestChild.getTotalValue();
    if (bestChildVal != Float.POSITIVE_INFINITY && bestChildVal != Float.NEGATIVE_INFINITY) {
      if (bestChild.getTotalVisits() == 0) {
        result = -1 * playOut(bestChild);
        n.addToValue(result);
        return result;
      } else {
        result = -1 * MCTSSolver(bestChild);
      }
    } else {
      result = bestChildVal;
    }
    if (result == Float.POSITIVE_INFINITY) {
      n.setValue(Float.NEGATIVE_INFINITY);
      return result;
    } else if (result == Float.NEGATIVE_INFINITY) {
      for (MCTNode child : n.getChildren()) {
        if (child.getTotalValue() != result) {
          result = -1;
          n.addToValue(result);
          return result;
        }
      }
      n.setValue(Float.POSITIVE_INFINITY);
      return result;
    }
    n.addToValue(result);
    return result;
  }
  
  private MCTNode select(MCTNode node, float exploreParam) {
    MCTNode selected = node;
    MCTNode[] children = node.getChildren();
    float bestValue = -1 * Float.MAX_VALUE;
    for (MCTNode child : children) {
      float uctValue = child.getUCBValue(exploreParam);
      if (uctValue > bestValue) {
        bestValue = uctValue;
        selected = child;
      }
    }
    return selected;
  }

  private MCTNode[] selectFew(MCTNode node, float exploreParam, int numToSelect) {
    // initialize variables and starting options
    MCTNode[] children = node.getChildren();
    if (children.length == 0) { // special case for no children to prevent NullPointerException
      return new MCTNode[]{node};
    }
    MCTNode[] bestFew = Arrays.copyOfRange(children, 0, min(numToSelect, children.length));
    float[] bestFewValues = new float[bestFew.length];
    for (int i = 0; i < bestFew.length; ++i) {
      bestFewValues[i] = bestFew[i].getUCBValue(exploreParam);
    }
    // look for better options
    for (int i = bestFew.length; i < children.length; ++i) {
      float uctValue = children[i].getUCBValue(exploreParam);
      for (int j = 0; j < bestFew.length; ++j) {
        if (uctValue > bestFewValues[j]) {
          bestFewValues[j] = uctValue;
          bestFew[j] = children[i];
          break;
        }
      }
    }
    return bestFew;
  }

  private MCTNode expand(MCTNode node) {
    node.generateChildren();
    for (MCTNode child : node.getChildren()) {
      if (child.getGameState().someWinConfirmed()) {
        child.setValue(Float.POSITIVE_INFINITY);
        return child;
      }
    }
    return select(node, EXPLORATION_PARAMETER);
  }

  private float playOut(MCTNode node) {
    node.addOneToVisits();
    GameState state = node.getGameState().getDuplicate();
    int[][] conBoard = state.getConnectionBoard();
    while (state.getWinner() == 0 || state.isTie()) {
      int[][] movePool = state.getMovePool(conBoard);
      if (movePool.length == 0) {
        break;
      }
      // get two possible moves, choose the one with the greater connection value
      int[] moveOption1 = movePool[int(random(movePool.length))];
      int[] moveOption2 = movePool[int(random(movePool.length))];
      int[] move = new int[2];
      if (moveOption1[2] >= moveOption2[2]) {
        move[0] = moveOption1[0];
        move[1] = moveOption1[1];
      } else {
        move[0] = moveOption2[0];
        move[1] = moveOption2[1];
      }
      int[] cc = state.getCaptureCount();
      state.playMove(move);
      conBoard = state.getConnectionBoard(conBoard, cc);
    }
    float result = (state.getWinner() == node.getGameState().getPlayerOfCurrentTurn()) ? -1 : 1;
    node.addToValue(result);
    return result;
  }
  
  private MCTNode secureChild(MCTNode rootNode, float exploreParam) {
    MCTNode[] children = rootNode.getChildren();
    MCTNode selected = children[0];
    float bestValue = -1 * Float.MAX_VALUE;
    for (MCTNode child : children) {
      float scValue = child.getLCBValue(exploreParam);
      if (scValue > bestValue) {
        bestValue = scValue;
        selected = child;
      }
    }
    return selected;
  }
}
