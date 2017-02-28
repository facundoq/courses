function dataset=estimate_initial_probabilities(dataset,k_poses)

for i=1:length(dataset)
    action_samples=dataset(i);
    [action_samples.InitialClassProb, action_samples.InitialPairProb]=estimate_initial_probabilities_class(action_samples,k_poses);
    dataset(i)=action_samples;
end

end

function [class_prob,pair_prob]= estimate_initial_probabilities_class(action_samples,k_poses)

poses=action_samples.poseData;
[n,parts,d]=size(poses);
poses=reshape(poses,n,parts*d);


% [best_pose,~,~,distances]=kmeans(poses,k_poses,'Replicates',4,'Distance','cityblock');
% class_prob=exp(-distances);

distributions=fitgmdist(poses,k_poses,'CovarianceType','diagonal','Replicates',2);
[best_pose,~,class_prob]=cluster(distributions,poses);
class_prob=rand(size(class_prob));
class_prob=bsxfun(@rdivide,class_prob,sum(class_prob,2));


actions=action_samples.actionData;
pair_prob=zeros(0,k_poses,k_poses);
t=1;
for i=1:length(actions)
    action=actions(i);
    best_action_poses=best_pose(action.marg_ind);
    for j=2:length(best_action_poses)
        from=best_action_poses(j-1);
        to=best_action_poses(j);
        pair_prob(t,:,:)=1;
        pair_prob(t,from,to)=pair_prob(t,from,to)+5;
        t=t+1;
    end

end

pair_prob=reshape(pair_prob,size(pair_prob,1),k_poses*k_poses);
pair_prob=rand(size(pair_prob));
pair_prob=bsxfun(@rdivide,pair_prob,sum(pair_prob,2));


  
end