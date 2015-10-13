% NoiseCloud feature extraction for ICA components ------------------------
% vsochat@stanford.edu

function [features_norm feature_labels network_paths] = noisecloud

% Features are read from the noisecloud database, and scripts to extract 
% them are written as temporary files in the "temp" folder.  For complete
% instructions, see INSTRUCTIONS.txt

% -------------------------------------------------------------------------
% Add path for noisecloud
fullpath = fileparts(which('noisecloud'));
addpath(genpath(fullpath));
global TR;

% Check for SPM
if isempty(which('spm')) 
   error('Please download SPM and add it to your path!'); 
end

% Ask the user to input images TR
TR = input('Enter TR value:');

% Ask the user image selection preference
choice = input('Select FSL directories (1), or images and timecourse files (2):');
switch choice
    case 1
        % Ask user to select data
        [ network_paths network_row_names ] = noisecloud_read_fsldirs;
    case 2
        [network_paths,~] = spm_select([1 Inf],'dir','Select thresholded Z-stat images:','','',{'.nii.gz','.nii','.img'});
        network_row_names = network_paths;
        [timeseries_paths,~] = spm_select([1 Inf],'dir','Select raw timeseries text files:','','','.txt');
        if size(timeseries_paths,1) ~= size(network_paths,1)
            error('You must select an equal number of timeseries and corresponding spatial maps!');
        end
end

% This will grab paths to atlases and tissue maps.  You must prepare these
% in advance to be registered to your data!  See INSTRUCTIONS.txt for details
noisecloud_setup


%% Step 1: GET FEATURES FROM noisecloud for download
fprintf('%s\n','Reading spatial and temporal features from noisecloud...');
spatial = urlread('http://vbmis.com/bmi/ncdb/rest/spat');
temporal = urlread('http://vbmis.com/bmi/ncdb/rest/temporal');

% Parse spatial and temporal features
fprintf('%s\n','Parsing feature data...');
% Parse json for subjects and concepts
[ spatial ~ ] = noisecloud_parse_json(spatial); spatial = spatial{1};
[ temporal ~ ] = noisecloud_parse_json(temporal); temporal = temporal{1};

feature_labels = [];
idx = 1;

% Write temporary scripts for spatial and temporal features
for s=1:size(spatial,2)
    nfeatures = str2num(spatial{s}.n);
    labels = regexp(spatial{s}.label,',','split');
    if nfeatures ~= size(labels,2) % If there is one label to describe features
        for f=1:nfeatures
            feature_labels{idx} = [ spatial{s}.label '.' num2str(f) ];
            idx = idx +1;
        end
    else % If there is a unique label per feature
        for f=1:nfeatures
            feature_labels{idx} = labels{f};
            idx = idx +1;
        end
    end
    script = fopen([ 'temp/' spatial{s}.name '.m' ],'w');
    lines = regexp(spatial{s}.code,';','split');
    fprintf(script,'%s',lines{1}); 
    for l=2:size(lines,2)
       fprintf(script,'%s\n%s',';',[ lines{l} ]); 
    end
    fclose(script);
end

for t=1:size(temporal,2)
    nfeatures = str2num(temporal{t}.n);
    labels = regexp(temporal{t}.label,',','split');
    if nfeatures ~= size(labels,2) % If there is one label to describe features
        for f=1:nfeatures
            feature_labels{idx} = [ temporal{t}.label '.' num2str(f) ];
            idx = idx + 1;
        end
    else % If there is a unique label per feature
        for f=1:nfeatures
                feature_labels{idx} = labels{f};
            idx = idx + 1;
        end
    end
    script = fopen([ 'temp/' temporal{t}.name '.m' ],'w');
    lines = regexp(spatial{s}.code,';','split');
    fprintf(script,'%s',lines{1}); 
    for l=2:size(lines,2)
        fprintf(script,'%s\n%s',';',[ lines{l} ]); 
    end
    fclose(script);
end


%% Step 2: Extract features

features = [];

for s=1:size(network_paths,1)
    fprintf('%s\n',[ 'Extracting features for ' network_row_names{s} ]);
    switch choice
       case 1 %FSL
           current_image = spm_read_vols(spm_vol(network_paths{s}));
           [~,fname] = fileparts(network_paths{s});
           ICnum = fname(regexp(fname,'zstat')+5:end);
           time_text = [ fileparts(fileparts(network_paths{s})) '\report\t' num2str(ICnum) '.txt' ];
       case 2 %OTHER
           current_image = network_paths{s};
           if regexp(current_image,'.nii.gz')
              current_image = gunzip(current_image); 
           end
           time_text = timeseries_paths{s};
   end
   
   % Read in timeseries
   time_file = fopen(time_text,'r');
   T = fscanf(time_file,'%f\t'); % Each timepoint is one TR
   fclose(time_file);
   
   temp_feat_vector = [];
   
    % Extract spatial features
    for sp=1:size(spatial,2)
        script = [ spatial{sp}.name '(current_image)' ];
        feat = eval(script);
        feat = reshape(feat,max(size(feat)),1);
        temp_feat_vector = [temp_feat_vector; feat ];
    end

    % Extract temporal features
    for tp=1:size(temporal,2)
        script = [ temporal{tp}.name '(T)' ];
        feat = eval(script);
        feat = reshape(feat,max(size(feat)),1);  
        temp_feat_vector = [temp_feat_vector; feat ];
    end
    
    features = [ features; temp_feat_vector' ]; clear temp_feat_vector
end

%% Step 3: Normalization

    features_norm = zeros(size(features));
    for i = 1:size(features_norm,2)
        single_feature = features(:,i);
        features_norm(:,i) = (single_feature - mean(single_feature)) / std(single_feature);
    end

    % Replace NaN with zero
    features_norm(isnan(features_norm)) = 0;
    
    fprintf('%s\n','Feature extraction complete.');
    fprintf('%s%s%s\n','     ',num2str(length(feature_labels)),' total features');
    fprintf('%s%s%s\n','     ',num2str(length(network_row_names)),' total networks');

end