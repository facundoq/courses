function datasetTrain=expand_dataset(datasetTrain,expand_factor,perturbation_factor)
expand_factor=expand_factor-1;
if expand_factor<=0
    return
end

for i=1:length(datasetTrain)
    class_samples=datasetTrain(i);
    [new_actions,new_poses]=perturb_class_actions(class_samples.actionData,class_samples.poseData,expand_factor,perturbation_factor);
    class_samples.actionData=[class_samples.actionData new_actions];
    class_samples.poseData=cat(1,class_samples.poseData,new_poses);
    datasetTrain(i)=class_samples;
end

end

function [perturbed_actions,perturbed_poses]=perturb_class_actions(actions,poses,expand_factor,perturbation_factor)
    last_marg_ind=actions(end).marg_ind(end);
    last_pair_ind=actions(end).pair_ind(end);
    
    perturbed_actions=[];
    perturbed_poses=zeros(0,size(poses,2),size(poses,3));
    for i=1:length(actions)
        action=actions(i);
        action_poses=poses(action.marg_ind,:,:);
        for k=1:expand_factor
            % generate perturbed poses
            perturbation_variance=mean(action_poses,1)*perturbation_factor;
            perturbation=randn(size(action_poses));
            perturbation=bsxfun(@times,perturbation,perturbation_variance);
            perturbed_poses_action=action_poses+perturbation;
            n_poses=size(perturbed_poses_action,1);
            
            % generate perturbed action
            % set action name
            perturbed_action.action=action.action;
            
            
            % set and update pair indices
            old_pair_ind=last_pair_ind;
            last_pair_ind=last_pair_ind+n_poses-1;
            perturbed_action.pair_ind=old_pair_ind:(last_pair_ind-1);
            
            % set and update marg indices
            old_marg_ind=last_marg_ind;
            last_marg_ind=last_marg_ind+n_poses;
            perturbed_action.marg_ind=old_marg_ind:(last_marg_ind-1);
            
            % add action and action's poses to the result
            perturbed_poses=cat(1,perturbed_poses,perturbed_poses_action);
            perturbed_actions=[perturbed_actions perturbed_action];
        end
    end
    
end