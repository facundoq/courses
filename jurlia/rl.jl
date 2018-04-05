module ReinforcementLearning

using Distributions

abstract ArmedBandit
end

type NormalDistributedArmedBandit <: ArmedBandit
  normals::Vector{Normal}

end

type ConstantArmedBandit <: ArmedBandit
  rewards::Vector{Float32}
end


function RandomNormalDistributedArmedBandit(n::Integer,u_range::Range,std_range::Range)
  means=rand(float(u_range),n)
  stds=rand(float(std_range),n)
  normals=map(p-> Normal(p[1],p[2]),zip(means,stds))
  NormalDistributedArmedBandit(normals)
end

function sample(b::NormalDistributedArmedBandit,i::Integer)
  rand(b.normals[i])
end

function RandomConstantArmedBandit(n::Integer,r::Range)
  ConstantArmedBandit(rand(float(r),n))
end

function sample(b::ConstantArmedBandit,i::Integer)
  b.rewards[i]
end

end
