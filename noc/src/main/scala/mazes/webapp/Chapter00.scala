package mazes.webapp

import org.scalajs.dom.raw.HTMLElement
import mazes.chapter00.Walker
import scala.scalajs.js.timers._
import mazes.math.Position
import mazes.math.Categorical
import mazes.math.Categorical
import scala.util.Random
import mazes.math.Normal


// Chapter00 is the Introduction
class Chapter00(base: HTMLElement) extends CanvasUI(base) {

  def play() {
    gaussianWalk
  }
  
  def gaussianWalk(){
    
  }
  def splatter(){
      ctx.fillStyle = "gray"
      println(canvasElement.width, canvasElement.height)
      ctx.fillRect(0, 0, canvasElement.width, canvasElement.height)
      
      
      val radiusRandom=new Normal(30,15)
      
      val mean=Position(canvasElement.width/2,canvasElement.height/2)
      val std=300
      val xRandom=new Normal(mean.x,std)
      val yRandom=new Normal(mean.y,std)
      
      def drawPosition()=Position(xRandom.draw.toInt,yRandom.draw.toInt)
      val colorRandom=new Normal(128,128)
      
    setInterval(50) {
      
      def drawColor()=1
      val p=drawPosition()
      ctx.beginPath()
      ctx.arc(p.x, p.y, Math.max(radiusRandom.draw,10), 0, 2*Math.PI)
      val hue=Math.max(colorRandom.draw(),5)
      ctx.fillStyle = s"hsl($hue,50%,50%)"
      ctx.fill()
//      ctx.lineWidth=2
//      ctx.strokeStyle="#000000"
      //ctx.stroke
    }
    
  }
  
  def walkers() {
    val center = Position(canvasElement.height / 2, canvasElement.width / 2)
    val w = new Walker(center)
    ctx.fillStyle = "gray"
    
    ctx.fillRect(0, 0, canvasElement.width, canvasElement.height)
    ctx.fillStyle = "black"

    ctx.fillRect(w.y - 1, w.x - 1, 3, 3)

    setInterval(50) {
      //Example 1
      //w.step4
      //w.step8

      //Exercise 1
      //val downright=new Categorical(List(0.245,0.245,0.255,0.255))
      //w.step4Distribution(downright)

      //example 3
      //val right=new Categorical(List(0.2,0.2,0.2,0.4))
      //w.step4Distribution(right)

      //Exercise 3

      val dynamic = new Categorical(mouseDirectionProbabilities(w.p))
      w.stepDistribution(dynamic, Position.d8)

      ctx.fillRect(w.y - 1, w.x - 1, 3, 3)
    }
    def mouseDirectionProbabilities(p: Position) = {
      val directionFromPointToMouse = (mousePosition - w.p).toDirection
      val nonPreferredDirectionProbability = 0.08
      val preferredDirectionProbability = 1 - nonPreferredDirectionProbability * 7
      var probabilities = List.fill(8)(nonPreferredDirectionProbability)
      val dIndex = Position.d8.indexOf(directionFromPointToMouse)
      //        println("Mouse: "+mousePosition+", pos:"+w.p+"->"+dIndex+",dir:"+directionFromPointToMouse)
      probabilities = probabilities.updated(dIndex, preferredDirectionProbability)
      probabilities
    }

  }
}