package mazes.math

object Position{
  def apply(x:Int,y:Int) = new Position(x,y)
  def apply() = new Position(0,0)
  val d4=List(Position(-1,0),Position(0,-1),Position(1,0),Position(0,1))
  val d5=List(Position(0,0))++d4
  val diag=List(Position(-1,-1),Position(-1,1),Position(1,1),Position(1,-1))
  val d8=d4++diag
  val d9=d5++diag
  
}
class Position(var x:Int, var y:Int){
  override def toString:String= s"($x,$y)"
  
  def +(t:(Int,Int))=Position(x+t._1,y+t._2)
  def -(t:(Int,Int))=Position(x-t._1,y-t._2)
  def +(p:Position)=Position(x+p.x,y+p.y)
  def -(p:Position)=Position(x-p.x,y-p.y)
  def *(d:Int)=Position(x*d,y*d)
  def /(d:Int)=Position(x/d,y/d)
  def /(d:Double)=Position((x/d).toInt,(y/d).toInt)
  def swap= Position(y,x)
  def norm2=x*x+y*y
  def norm= Math.sqrt(norm2)
  def normalized= this/this.norm
  def toDirection=Position(Integer.signum(x),Integer.signum(y))
  
    def canEqual(a: Any) = a.isInstanceOf[Position]
    override def equals(that: Any): Boolean =
        that match {
            case that: Position => that.canEqual(this) && x==that.x && y ==that.y
            case _ => false
     }
    override def hashCode: Int = {
        return x.hashCode()
    }
}
