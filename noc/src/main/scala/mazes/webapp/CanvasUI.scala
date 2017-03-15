package mazes.webapp


import org.scalajs.dom.raw.HTMLElement
import org.scalajs.dom.raw.HTMLCanvasElement
import scalatags.JsDom.all._
import org.scalajs.dom.CanvasRenderingContext2D
import org.scalajs.dom.raw.MouseEvent
import mazes.math.Position


abstract class CanvasUI(var base: HTMLElement){
    var canvasElement= canvas(style:="border 1px solid").render
    canvasElement.height=700
    canvasElement.width=700
    // val canvas = dom.document.createElement("canvas").asInstanceOf[Canvas]
    val ctx = canvasElement.getContext("2d").asInstanceOf[CanvasRenderingContext2D]
    
    var mousePosition=Position()
    
    
    def setupUI(){
      base.appendChild(canvasElement)
      canvasElement.onmousemove = { (e: MouseEvent) =>  updateMousePosition(e)}
      canvasElement.onmouseenter = { (e: MouseEvent) =>  updateMousePosition(e)}
    }
    def updateMousePosition(e:MouseEvent){
      mousePosition.y=(e.clientX-canvasElement.getBoundingClientRect().left).toInt
      mousePosition.x=(e.clientY-canvasElement.getBoundingClientRect().top).toInt
    }
    def play
    
  
  
}