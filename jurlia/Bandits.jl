module Bandits

export Bandit, ConstantBandit,NormalDistributedBandit,NonStationaryModifier,RandomWalk,Stationary,RandomConstantBandit,RandomNormalDistributedBandit,bandits, sample, update


using Distributions

abstract Bandit

type NormalDistributedBandit <: Bandit
  normals::Vector{Normal}
end
type ConstantBandit <: Bandit

  rewards::Vector{Float32}
end

abstract NonStationaryModifier

type RandomWalk <: NonStationaryModifier
  delta::Float32
  p::Float32
end
type Stationary <: NonStationaryModifier

end

function RandomNormalDistributedBandit(n::Integer,u_range::Range,std_range::Range)
  means=rand(float(u_range),n)
  stds=rand(float(std_range),n)
  normals=map(p-> Normal(p[1],p[2]),zip(means,stds))
  NormalDistributedBandit(normals)
end

function sample(b::NormalDistributedBandit,i::Integer)
  rand(b.normals[i])
end

function RandomConstantBandit(n::Integer,r::Range)
  ConstantBandit(rand(float(r),n))
end

function sample(b::ConstantBandit,i::Integer)
  b.rewards[i]
end

function update(b::ConstantBandit, m::Stationary)
end

function update(b::NormalDistributedBandit, m::Stationary)
end

function update(b::ConstantBandit, m::RandomWalk)
  n=bandits(b)
  deltas=m.delta*rand(n)-0.5
  changes=rand(n).<m.p
  b.rewards=b.rewards+deltas .* changes
end

function update(b::NormalDistributedBandit, m::RandomWalk)
  n=bandits(b)
  for i=1:n
    delta=m.delta*rand()-0.5
    change=rand()<m.p
    b.normals[i]=Normal(b.normals[i].μ+delta*change,b.normals[i].σ)
  end
end

function bandits(b::ConstantBandit)
  return length(b.rewards)
end

function bandits(b::NormalDistributedBandit)
  return length(b.normals)
end

function sample(b::Bandit)
  n=bandits(b)
  map(i-> sample(b,i),1:n)
end


end
