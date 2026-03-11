function modelnames  = getlistofmodels(wbHndl, paths, varargin)

%returns details of all the models in the directories in 'path'

%wbHndl is handle to a progress bar gui. Must be empty if there isn't one

%paths is cell array, usually 'oscillator' and 'signal' directories. Full
%paths needed

%varargin{1} is 'all' to return list of all models found,
%               'results' to return all models with results files
%               'theory' to return all models with results files which
%               include theory results

%varargin{2} can be the name of a model, in which case only get details for
%model matching the above criteria and having this name. If more than one
%path is specified and matching models are present on more than one path,
%only the first found will be returned
%Can also be a numeric value, in which case get the first model found that
%meets the criteris defined by varargin{1}

modelnames = [];
%defaults - find all models
filetype = 'all';
nametofind = [];
findonlyonemodel = false;

if ~isempty(varargin)
    filetype = varargin{1};
    if length(varargin) > 1
        nametofind = varargin{2};
        findonlyonemodel = true;
    end
end

%first count the number of models. This is just for progress bar

if isempty(nametofind) && ~isempty(wbHndl)
    nummodels = 0;
    for p = 1:length(paths)
        modelpath = paths{p};
        modeldir = dir(modelpath);
        for m = 1:length(modeldir)
            if modeldir(m).isdir && modeldir(m).name(1) ~= '.'
                nummodels = nummodels+1;
            end
        end
    end
else
    nummodels = 1;
end

for p = 1:length(paths)
    modelpath = paths{p};
    modeldir = [];
    if ischar(nametofind)
        if exist(fullfile(paths{p}, nametofind), 'dir') == 7
            modeldir.isdir=1;
            modeldir.name=nametofind;
        end
    else
        modeldir = dir(modelpath);
    end
    if ~isempty(modeldir)
        for i = 1:size(modeldir,1)
            if modeldir(i).isdir && modeldir(i).name(1) ~= '.'
                %found a subfolder whose name doesn't begin with ., ie ., .., or .svn
                n = modeldir(i).name;
                
                if ~isempty(wbHndl)
                    waitbar((length(modelnames)+1)/(nummodels+3),wbHndl,['Searching for models... ' strrep(n, '_', ' ')]);
                end
                
                if exist(fullfile(modelpath, n , [n, '.par']), 'file') && exist(fullfile(modelpath, n , [n, '.varn']), 'file') ...
                        && exist(fullfile(modelpath, n , [n, '.info']), 'file')
                    
                    %find result files in this folder
                    dbfile = fullfile(modelpath, n, 'results', 'results.db');
                    tmpf = cell(0);
                    tmpt = [];
                    hastheory = false;
                    if exist(dbfile, 'file') == 2
                        fc = load(dbfile, '-mat');
                        db = fc.db;
                        toremove = [];
                        for f = 1:length(db)
                            if ~strcmp(filetype, 'theory') || db{f}.theory
                                %Either file has theory in it, or we aren't
                                %filtering on this
                                if exist(fullfile(modelpath, n, 'results', db{f}.name),'file') == 2
                                    tmpf{end+1} = db{f}.name;
                                    tmpt(end+1) = db{f}.theory;
                                else
                                    %remove any non-existant file from database
                                    toremove = [toremove f];
                                end
                            end
                        end
                        if ~isempty(toremove)
                            db(toremove) = [];
                            save(dbfile, 'db');
                        end
                    end
                    %If filetype is 'all', include model. In this case
                    %model.files will list all its results files
                    %If filetype is 'results', include model if it has results files.
                    %In this case model.files will list all its results files
                    %If filetype is 'theory' include model if it has at least
                    %one results file with 'theory in it. In this case
                    %model.files will list only results with 'theory' in them.
                    
                    if strcmp(filetype, 'all') ||  ~isempty(tmpf)
                        mdl.name = n;
                        type = regexp(modelpath, '[\\/]', 'split');
                        mdl.type = lower(type{end});
                        mdl.dir = fullfile(modelpath, mdl.name);
                        fid_tmp = fopen(fullfile(mdl.dir,  [mdl.name, '.par']), 'r');
                        tmp_scan = textscan(fid_tmp, '%s %f %[^\n]');
                        fclose(fid_tmp);
                        parn = tmp_scan{1}; parv = tmp_scan{2}; parnames = tmp_scan{3};
                        mdl.parn = parn;
                        mdl.parnames = parnames;
                        mdl.parv = parv; %default values
                        mdl.pnum = length(mdl.parn);
                        %check the number of model variables
                        fid_tmp = fopen(fullfile(mdl.dir,  [mdl.name, '.varn']), 'r');
                        tmp_scan = textscan(fid_tmp, '%s %f %[^\n]');
                        fclose(fid_tmp);
                        varn = tmp_scan{1}; init_cond = tmp_scan{2}; vardesc = tmp_scan{3};
                        mdl.vnum = length(varn);
                        mdl.vnames = varn;
                        mdl.vardesc = vardesc;
                        mdl.init_cond = init_cond;
                        mdl.files = tmpf;
                        mdl.theory = tmpt;  %NOT USED
                        mdl.hastheory = any(tmpt);  %Just record whether ANY file has dgs.
                        %Determines if this model should appear in sagui
                        
                        %read info file
                        fid_tmp = fopen(fullfile(mdl.dir, [mdl.name '.info']), 'r');
                        tmp_scan = textscan(fid_tmp, '%[^\n]');
                        fclose(fid_tmp);
                        fc = tmp_scan{1};
                        idx = find(strcmp(fc, 'tend'));
                        mdl.tend = fc{idx+1};
                        idx = find(strcmp(fc, 'method'));
                        mdl.ode_method = fc{idx+1};
                        idx = find(strcmp(fc, 'force_type'));
                        mdl.force_type = [];
                        %this is now a comma seperated list, of form -
                        %name1 type dawn1 dusk1, name2 type dawn2 dusk2, ...
                        if ~isempty(idx)%allow for models with no force
                            str = fc{idx+1};
                            [ft, str] = strtok(str, ',');
                            while ~isempty(ft)
                                ft=textscan(ft, '%s %s %f %f');
                                tmp.name = char(ft{1}); %force, force1, etc ... these will be in alphabetical order
                                tmp.type = char(ft{2}); %'photo', 'cts', etc ...
                                tmp.dawn = ft{3};
                                tmp.dusk = ft{4};
                                mdl.force_type = [ mdl.force_type tmp];
                                [ft, str] = strtok(str, ',');
                            end
                        end
                        mdl.numforce = length(mdl.force_type);
                        %%mdl.pnum  = mdl.pnum + 2 * mdl.numforce;%%?????
                        idx = find(strcmp(fc, 'cycle_period'));
                        mdl.cycle_period = fc{idx+1};
                        idx = find(strcmp(fc, 'positivity'));
                        mdl.positivity = fc{idx+1};
                        idx = find(strcmp(fc, 'orbit_type'));
                        mdl.orbit_type = fc{idx+1};
                        idx = find(strcmp(fc, 'plotting_timescale'));
                        mdl.plotting_timescale = str2double(fc{idx+1});
                        idx = find(strcmp(fc, 'dim'));
                        mdl.dim = fc{idx+1};
                        modelnames = [modelnames mdl];
                        if findonlyonemodel
                            %Here user has specified a particular model. Found
                            %it so stop
                            return;
                        end
                    end%end ~isempty(m) || allmodels
                    clear mdl;
                    
                else
                    
                    ShowError(['Model ' n ' is incomplete. This model will need to be re-installed before it can be used']);
                    
                    
                end
                
            end%end if modeldir(i).isdir && ~strcmp(modeldir(i).name, '.') && ~strcmp(modeldir(i).name, '..')
        end% end i = 1:size(modeldir,1)
    end%end ~isempty(modeldir)
end%end p = 1:length(paths)



