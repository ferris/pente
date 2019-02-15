import java.util.*;

class ABNode {
  private short value;
  private byte[][] board;
  private byte[] move;
  private byte oCaptures;
  private byte tCaptures;
  private ABNode parent;
  private List<ABNode> children = new ArrayList<ABNode>();

  ABNode(byte[][] board, byte oCaptures, byte tCaptures, byte[] move, byte player) {
    // deep copy to prevent collisions
    this.board = new byte[Game.n][Game.n];
    for (int i = 0; i < Game.n; ++i) {
      for (int j = 0; j < Game.n; ++j) {
        this.board[i][j] = board[i][j];
      }
    }
    this.oCaptures = oCaptures;
    this.tCaptures = tCaptures;
    this.move = move.clone();
    if (player == 1) {
      this.oCaptures += game.isCaptureMove(this.board, player, this.move);
    } else if (player == 2) {
      this.tCaptures += game.isCaptureMove(this.board, player, this.move);
    }
    this.board[move[0]][move[1]] = player;
  }
}


class ABObj {
  short value;
  byte[] move;

  ABObj(short value, byte[] move) {
    this.value = value;
    if (move.length != 2) {
      throw new IllegalArgumentException("Move has to be of length 2; {x, y}");
    }
    this.move = move;
  }
}


class GameAI {
  private final byte SIZE = 19;
  private byte[] prevMove;
  private byte oCaptures = 0;
  private byte tCaptures = 0;
  private byte depth;

  GameAI(byte depth) {
    this.depth = depth;
  }

  public byte[] getComputerMove(byte[][] board, byte oCaptures, byte tCaptures, byte player) {
    // find opposite player
    byte unPlayer;
    if (player == 1) {
      unPlayer = 2;
    } else {
      unPlayer = 1;
    }
    int beginTime = millis();
    // generate ABP value board and find the maximum value within
    short[][] abValueBoard = new short[Game.n][Game.n];
    short bestValue = 0;
    short currentMax = Short.MIN_VALUE;
    short currentMin = Short.MAX_VALUE;
    for (byte i = 0; i < Game.n; ++i) {
      for (byte j = 0; j < Game.n; ++j) {
        print("Now analyzing move: "); println((i*Game.n)+j+1);
        if (board[i][j] == 0) {
          ABNode testingNode = new ABNode(board, oCaptures, tCaptures, new byte[]{i, j}, player);
          /* deletable start (during second stage where this is moved to ABNode's constructor)
          if (player == 1) {
            testingNode.oCaptures += game.isCaptureMove(testingNode.board, player, testingNode.move);
          } else if (player == 2) {
            testingNode.tCaptures += game.isCaptureMove(testingNode.board, player, testingNode.move);
          }
          testingNode.board[i][j] = player;
          */ //deletable end
          
          if (player == 1) {
            abValueBoard[i][j] = alphabeta(testingNode, byte(depth-1), Short.MIN_VALUE, currentMin, unPlayer);
          } else if (player == 2) {
            abValueBoard[i][j] = alphabeta(testingNode, byte(depth-1), currentMax, Short.MAX_VALUE, unPlayer);
          }
          //print("this_value: "); println(abValueBoard[i][j]);
          //print("current_max: "); println(currentMax);
          if (currentMax < abValueBoard[i][j]) {
            println("GOTTA GET NEW MAX");
          }
          //abValueBoard[i][j] = alphabeta(testingNode, byte(depth-1), Short.MIN_VALUE, Short.MAX_VALUE, unPlayer);
          int currentMemory = int((Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory())/1048576);
          //print("current_memory: "); print(currentMemory); println(" MiB");
          if (currentMemory > 1024) {
            //println("Garbage collecting!");
            System.gc();
          }
          currentMin = (short)(min(currentMin, abValueBoard[i][j]));
          currentMax = (short)(max(currentMax, abValueBoard[i][j]));
        } else {
          // in case it isn't a valid move, it cannot be kept as 0
          if (player == 1) {
            abValueBoard[i][j] = Short.MAX_VALUE;
          } else {
            abValueBoard[i][j] = Short.MIN_VALUE;
          }
        }
      }
    }
    // cycle through board looking for the best value moves
    if (player == 1) {
      bestValue = currentMin;
    } else if (player == 2) {
      bestValue = currentMax;
    }
    List<byte[]> suitableMoves = new ArrayList<byte[]>();
    for (byte i = 0; i < Game.n; ++i) {
      for (byte j = 0; j < Game.n; ++j) {
        if (abValueBoard[i][j] == bestValue) {
          suitableMoves.add(new byte[]{i, j});
        }
      }
    }
    int timeTaken = millis() - beginTime;
    println("Processing time: " + timeTaken + "ms");
    println("minval: " + currentMin);
    println("maxval: " + currentMax);
    println("value: " + bestValue);
    return suitableMoves.get(0);
  }

  short alphabeta(ABNode node, byte currentDepth, short alpha, short beta, byte player) {
    if (currentDepth == 0) {
      // leaf node
      return heuristic(node.board, node.oCaptures, node.tCaptures);
    } else if (player == 2) {
      // maximizing player
      short value = Short.MIN_VALUE;
      for (byte i = 0; i < Game.n; ++i) {
        for (byte j = 0; j < Game.n; ++j) {
          byte[] move = {i, j};
          if (game.isValidMove(node.board, move)) {
            ABNode child = new ABNode(node.board, node.oCaptures, node.tCaptures, move, player);
            // child.tCaptures += game.isCaptureMove(child.board, player, child.move);
            // child.board[move[0]][move[1]] = player;
            value = (short)(max(value, alphabeta(child, byte(currentDepth-1), alpha, beta, byte(1))));
            alpha = (short)(max(alpha, value));
            if (alpha >= beta) {
              break; // beta cut-off
            }
          }
        }
      }
      return value;
    } else {
      // minimizing player
      short value = Short.MAX_VALUE;
      for (byte i = 0; i < Game.n; ++i) {
        for (byte j = 0; j < Game.n; ++j) {
          byte[] move = {i, j};
          if (game.isValidMove(node.board, move)) {
            ABNode child = new ABNode(node.board, node.oCaptures, node.tCaptures, move, player);
            // child.oCaptures += game.isCaptureMove(child.board, player, child.move);
            // child.board[move[0]][move[1]] = player;
            value = (short)(min(value, alphabeta(child, byte(currentDepth-1), alpha, beta, byte(2))));
            beta = (short)(min(beta, value));
            if (alpha >= beta) {
              break; // alpha cut-off
            }
          }
        }
      }
      return value;
    }
  }

  short heuristic(byte[][] board, byte oCaptures, byte tCaptures) {
    return captureDifferenceHt(oCaptures, tCaptures);
  }

  short captureDifferenceHt(byte oCaptures, byte tCaptures) {
    return (short)(tCaptures - oCaptures);
  }
}