%% plots gait kinematics using basic_data_preprocessing
figure(2)
title('gait kinematics')
subplot(2,1,1);
joint='knee';
shadedErrorBar(meanvals.(joint).joint_state.Header,meanvals.(joint).joint_state.Theta,std_vals.(joint).joint_state.Theta,'b');
title(joint);
subplot(2,1,2);
joint='ankle';
shadedErrorBar(meanvals.(joint).joint_state.Header,meanvals.(joint).joint_state.Theta,std_vals.(joint).joint_state.Theta,'b');
title(joint);