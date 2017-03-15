package mazes.webapp

// tutorial https://www.scala-js.org/tutorial/basic/
// canvas https://github.com/vmunier/scalajs-simple-canvas-game/blob/master/src/main/scala/simplegame/SimpleCanvasGame.scala

import scala.scalajs.js.JSApp
import org.scalajs.dom
import org.scalajs.dom.Element

import dom.document
import scala.scalajs.js.annotation.JSExport
import scalatags.JsDom.all._
import org.scalajs.dom.html._


object Main extends JSApp {
  
  def main(): Unit = {
    val ui=new Chapter00(document.body)
    ui.setupUI()
    //ui.drawMaze()
    ui.play
    
  }
  
  


}

