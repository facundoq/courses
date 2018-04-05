push!(LOAD_PATH, dirname(@__FILE__))

using ReinforcementLearning
using Bandits

function display_bandits(b::Bandit,m::NonStationaryModifier,iterations::Integer)
  for i=1:iterations
    println(sample(b))
    update(b,m)
  end
end



b= RandomConstantBandit(20,-5:5)
b= RandomNormalDistributedBandit(20,-5:5,0.1:0.2)
m= Stationary()
m= RandomWalk(1,0.1)
iterations=10
display_bandits(b,m,iterations)
