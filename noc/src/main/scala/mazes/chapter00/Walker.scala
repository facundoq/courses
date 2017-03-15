package mazes.chapter00

import scala.util.Random
import mazes.math.Categorical
import mazes.math.Position

class Walker(var p: Position) {
  
  def x = p.x
  def y = p.y
  override def toString: String = s"Walker $p"

  def step() { step8 }
  
  def stepDistribution(c:Categorical, v:List[Position]){
    assert(c.probabilities.length==v.length)
    val d = c.draw()
    p+= v(d)
  }
  def step8Distribution(c: Categorical) {
    stepDistribution(c, Position.d8)
    
  }
  
  def step4Distribution(c: Categorical) {
     stepDistribution(c, Position.d4)
  }
  
  
  def step8downright() {
    val r = new Random()

    p+= (r.nextInt(4) - 1,r.nextInt(4) - 1)

  }

  def step8() {
    val r = new Random()
    p+= (r.nextInt(3) - 1,r.nextInt(3) - 1)

  }

  def step4() {
    val r = new Random()
    val d = r.nextInt(4)
    p+= Position.d4(d)
  }

}