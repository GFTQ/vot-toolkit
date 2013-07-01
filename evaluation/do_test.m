script_directory = fileparts(mfilename('fullpath'));
include_dirs = cellfun(@(x) fullfile(script_directory,x), {'', 'utilities', 'tracker', 'sequence', 'measures', 'experiment'}, 'UniformOutput', false); 
if exist('strsplit') ~= 2
	remove_dirs = include_dirs;
else
	% if strsplit is available we can filter out missing paths to avoid warnings
	remove_dirs = include_dirs(ismember(include_dirs, strsplit(path, pathsep)));
end;
if ~isempty(remove_dirs) 
	rmpath(remove_dirs{:});
end;
addpath(include_dirs{:});

initialize_environment;

global current_sequence;
global trajectory;

if ~exist('trajectory', 'var')
	trajectory = [];
end;

if ~exist('current_sequence', 'var')
	current_sequence = 1;
end;

i = 0;
while 1
    print_text('Choose action:');
    print_indent(1);

    for i = 1:length(sequences)
        print_text('%d - Use sequence "%s"', i, sequences{i}.name);
    end;
    if ~isempty(trajectory)
        print_text('c - Visually compare results with the groundtruth');
    end;
    if track_properties.debug
        print_text('d - Disable debug output');
    else
        print_text('d - Enable debug output');
    end;
    print_text('e - Exit');
    print_indent(-1);

    option = input('Choose action: ', 's');

    switch option
    case 'c'
        if ~isempty(trajectory) && current_sequence > 0 && current_sequence <= length(sequences)
            visualize_sequence(sequences{current_sequence}, trajectory);
        end;        
	case 'd'
		track_properties.debug = ~track_properties.debug;
    case 'e'
        break;
    case 'q'
        break;

    end;

    current_sequence = int32(str2double(option));

    if isempty(current_sequence) || current_sequence < 1 || current_sequence > length(sequences)
        continue;
    end;

    print_text('Sequence "%s"', sequences{current_sequence}.name);
    [trajectory, time] = run_tracker(tracker, sequences{current_sequence}, 1);

end;





