function selectionInfo = HeuristicCorrelation(~, input, output)
selectionInfo = FeatureSelector.Heuristic(false, input, output);


for feature = 1:width(input)
    for feature2 = 1:width(input)
        correlation_matrix(feature, feature2) = corr2(input{:,feature}, input{:,feature2});
    end
end
% http://vision.stanford.edu/teaching/cs231b_spring1415/slides/lecture2_segmentation.pdf
% b = bar3(correlation_matrix);
% for k = 1:length(b)
%     zdata = b(k).ZData;
%     b(k).CData = zdata;
%     b(k).FaceColor = 'interp';
% end
affinity = correlation_matrix - min(correlation_matrix); % positive def

% figure,imshow(affinity,[]), title('Affinity Matrix')
% compute the degree matrix
for i=1:size(affinity,1)
    D(i,i) = sum(affinity(i,:));
end
% compute the normalized laplacian / affinity matrix (method 1)
%NL1 = D^(-1/2) .* L .* D^(-1/2);
for i=1:size(affinity,1)
    for j=1:size(affinity,2)
        NL1(i,j) = affinity(i,j) / (sqrt(D(i,i)) * sqrt(D(j,j)));
    end
end
% compute the normalized laplacian (method 2)  eye command is used to
% obtain the identity matrix of size m x n
% NL2 = eye(size(affinity,1),size(affinity,2)) - (D^(-1/2) .* affinity .* D^(-1/2));
% perform the eigen value decomposition
[eigVectors,eigValues] = eig(NL1);
% select k largest eigen vectors
k = 10;
nEigVec = eigVectors(:,(size(eigVectors,1)-(k-1)): size(eigVectors,1));
% construct the normalized matrix U from the obtained eigen vectors
for i=1:size(nEigVec,1)
    n = sqrt(sum(nEigVec(i,:).^2));
    U(i,:) = nEigVec(i,:) ./ n;
end
% perform kmeans clustering on the matrix U
[IDX,C] = kmeans(U,k);
% plot the eigen vector corresponding to the largest eigen value
%figure,plot(IDX)
[~,i] = sort(IDX);
% figure
% b = bar3(correlation_matrix(i,i));
% for k = 1:length(b)
%     zdata = b(k).ZData;
%     b(k).CData = zdata;
%     b(k).FaceColor = 'interp';
% end
correlation_matrix = correlation_matrix(i,i);
end
%
%         for feat2 = 1:length(names)
%             correlation_matrix(feat, feat2) = corr2(ALLDATA.(char(names(feat))), ALLDATA.(char(names(feat2))));
%         end
%     end
%     %% Normalizing
%     correlation_matrix(isnan(correlation_matrix)) = 1;
%     correlation_matrix = (1-correlation_matrix)/2;
%
%     speed_heuristic = speed_heuristic_vals(:,1)./speed_heuristic_vals(:,2);
%     speed_heuristic = speed_heuristic + abs(min(speed_heuristic));
%
%     gait_heuristic = gait_heuristic_vals(:,1)./gait_heuristic_vals(:,2);
%     gait_heuristic = gait_heuristic + abs(min(gait_heuristic));
%     %% Determine the best features
%     [~, unordered_features_speed] = sort(speed_heuristic(~isnan(speed_heuristic)),'descend');
%     unordered_features_speed = unordered_features_speed' + 1; % removing speed which is the first feature in table
%     easter egg -- if you find this, text me at (619) 768-3627 and I will
%     personally buy you ice cream
%     ordered_features_speed = zeros(1,length(names));
%     local_heuristic_speed = speed_heuristic;
%     for i = 1:length(names)
%         [~, feat] = max(local_heuristic_speed);
%         ordered_features_speed(i) = feat;
%         local_heuristic_speed = local_heuristic_speed.*correlation_matrix(feat,:)';
%     end
%
%     [~, unordered_features_gait] = sort(gait_heuristic(~isnan(gait_heuristic)),'descend');
%     unordered_features_gait = unordered_features_gait' + 1; % removing speed which is the first feature in table
%     ordered_features_gait = zeros(1,length(names));
%     local_heuristic_gait = gait_heuristic;
%     for i = 1:length(names)
%         [~, feat] = max(local_heuristic_gait);
%         ordered_features_gait(i) = feat;
%         local_heuristic_gait = local_heuristic_gait.*correlation_matrix(feat,:)';
%     end
%     toc