
void mainMenu() {
  noStroke();
  background(26, 188, 156);
  fill(44, 62, 80);
  rect(150, 300, 500, 100, 50);
  textAlign(CENTER);
  textSize(11);
  text(version, 730, 10);
  textSize(118);
  text("Pente", 400, 200);
  fill(236, 240, 241);
  textSize(72);
  text("PLAY", 400, 375);

  // play button
  if (mouseReleased && mouseX > 150 && mouseX < 650 && mouseY < 400 && mouseY > 150) {
    room = "modeMenu";
  }
}

void modeMenu() {
  noStroke();
  background(26, 188, 156);
  fill(44, 62, 80);
  rect(200, 50, 400, 100, 50);
  rect(200, 250, 400, 100, 50);
  rect(200, 450, 400, 100, 50);
  rect(75, 50, 50, 500, 25);
  fill(236, 240, 241);
  triangle(85, 275, 115, 305, 115, 245);
  textAlign(CENTER);
  textSize(118);
  textSize(42);
  text("Single Player", 400, 115);
  text("Local Multiplayer", 400, 315);
  text("Zero Players", 400, 515);

  // BUTTONS
  // single player button
  if (mouseReleased && mouseX > 200 && mouseX < 600 && mouseY < 150 && mouseY > 50) {
    room = "singleMenu";
  }
  // local multiplayer button
  if (mouseReleased && mouseX > 200 && mouseX < 600 && mouseY < 350 && mouseY > 250) {
    game = new Game("local", 1);
    room = "game";
  }
  // zero players button
  if (mouseReleased && mouseX > 200 && mouseX < 600 && mouseY < 550 && mouseY > 450) {
    room = "zeroMenu";
  }
  // back button
  if (mouseReleased && mouseX > 75 && mouseX < 125 && mouseY < 550 && mouseY > 50) {
    room = "mainMenu";
  }
}

void singleMenu() {
  noStroke();
  background(26, 188, 156);
  fill(44, 62, 80);
  rect(200, 50, 400, 100, 50);
  rect(200, 250, 400, 100, 50);
  rect(200, 450, 400, 100, 50);
  rect(75, 50, 50, 500, 25);
  fill(236, 240, 241);
  triangle(85, 275, 115, 305, 115, 245);
  textAlign(CENTER);
  textSize(118);
  textSize(42);
  text("Easy", 400, 115);
  text("Medium", 400, 315);
  text("Hard", 400, 515);
  // BUTTONS
  // easy button
  if (mouseReleased && mouseX > 200 && mouseX < 600 && mouseY < 150 && mouseY > 50) {
    game = new Game("single", 1);
    ai = new GameAI(4000);
    room = "game";
  }
  // medium button
  if (mouseReleased && mouseX > 200 && mouseX < 600 && mouseY < 350 && mouseY > 250) {
    game = new Game("single", 1);
    ai = new GameAI(8000);
    room = "game";
  }
  // hard button
  if (mouseReleased && mouseX > 200 && mouseX < 600 && mouseY < 550 && mouseY > 450) {
    game = new Game("single", 1);
    ai = new GameAI(16000);
    room = "game";
  }
  // back button
  if (mouseReleased && mouseX > 75 && mouseX < 125 && mouseY < 550 && mouseY > 50) {
    room = "modeMenu";
  }
}

void zeroMenu() {
  noStroke();
  background(26, 188, 156);
  fill(44, 62, 80);
  rect(200, 50, 400, 100, 50);
  rect(200, 250, 400, 100, 50);
  rect(200, 450, 400, 100, 50);
  rect(75, 50, 50, 500, 25);
  fill(236, 240, 241);
  triangle(85, 275, 115, 305, 115, 245);
  textAlign(CENTER);
  textSize(118);
  textSize(42);
  text("Dumb", 400, 115);
  text("Competent", 400, 315);
  text("Smart", 400, 515);
  // BUTTONS
  // dumb button
  if (mouseReleased && mouseX > 200 && mouseX < 600 && mouseY < 150 && mouseY > 50) {
    game = new Game("zero", 1);
    ai = new GameAI(1000);
    room = "game";
  }
  // competent button
  if (mouseReleased && mouseX > 200 && mouseX < 600 && mouseY < 350 && mouseY > 250) {
    game = new Game("zero", 1);
    ai = new GameAI(4000);
    room = "game";
  }
  // smart button
  if (mouseReleased && mouseX > 200 && mouseX < 600 && mouseY < 550 && mouseY > 450) {
    game = new Game("zero", 1);
    ai = new GameAI(16000);
    room = "game";
  }
  // back button
  if (mouseReleased && mouseX > 75 && mouseX < 125 && mouseY < 550 && mouseY > 50) {
    room = "modeMenu";
  }
}
