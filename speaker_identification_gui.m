function speaker_identification_gui
    global data sound_number fs nBits;
    
    fig = figure('Name', 'Voice Recognition System', 'NumberTitle', 'off', 'Position', [100, 100, 900, 700], 'MenuBar', 'none', 'ToolBar', 'none', 'Color', [0.95, 0.95, 0.97], 'Resize', 'off');

    tabGroup = uitabgroup(fig, 'Position', [0.02, 0.02, 0.96, 0.96], 'TabLocation', 'top');
    
    addVoiceTab = uitab(tabGroup, 'Title', '🎤 Add Voice', 'BackgroundColor', [0.98, 0.98, 1.0]);
    setupAddVoiceTab(addVoiceTab);
    
    identifyTab = uitab(tabGroup, 'Title', '🔍 Identify Speaker', 'BackgroundColor', [0.98, 1.0, 0.98]);
    setupIdentifyTab(identifyTab);
    
    databaseTab = uitab(tabGroup, 'Title', '📊 Database', 'BackgroundColor', [1.0, 0.98, 0.98]);
    setupDatabaseTab(databaseTab);
end

function setupAddVoiceTab(parent)
    global data sound_number fs nBits;
    
    headerPanel = uipanel('Parent', parent, 'Units', 'normalized', 'Position', [0.05, 0.85, 0.9, 0.1], 'BackgroundColor', [0.2, 0.4, 0.8], 'BorderType', 'none', 'ForegroundColor', 'white');
    
    uicontrol('Parent', headerPanel, 'Style', 'text', 'String', '🎤 Voice Registration', 'FontSize', 18, 'FontWeight', 'bold', 'Units', 'normalized', 'Position', [0.1, 0.2, 0.8, 0.6], 'BackgroundColor', [0.2, 0.4, 0.8], 'ForegroundColor', 'white');

    inputPanel = uipanel('Parent', parent, 'Units', 'normalized', 'Position', [0.1, 0.65, 0.8, 0.15], 'BackgroundColor', [0.97, 0.97, 0.99], 'BorderType', 'line', 'HighlightColor', [0.7, 0.7, 0.9], 'ShadowColor', [0.9, 0.9, 0.9]);

    uicontrol('Parent', inputPanel, 'Style', 'text', 'String', 'Enter Your Name:', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'left', 'Units', 'normalized', 'Position', [0.05, 0.65, 0.3, 0.25], 'BackgroundColor', [0.97, 0.97, 0.99]);
    
    nameEdit = uicontrol('Parent', inputPanel, 'Style', 'edit', 'String', '', 'FontSize', 11, 'Units', 'normalized', 'Position', [0.4, 0.65, 0.5, 0.25], 'BackgroundColor', 'white');

    uicontrol('Parent', inputPanel, 'Style', 'text', 'String', 'Recording Duration (1-10 sec):', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'left', 'Units', 'normalized', 'Position', [0.05, 0.25, 0.3, 0.25], 'BackgroundColor', [0.97, 0.97, 0.99]);
    
    durationEdit = uicontrol('Parent', inputPanel, 'Style', 'edit', 'String', '3', 'FontSize', 11, 'Units', 'normalized', 'Position', [0.4, 0.25, 0.15, 0.25], 'BackgroundColor', 'white');

    controlPanel = uipanel('Parent', parent, 'Units', 'normalized', 'Position', [0.1, 0.5, 0.8, 0.1], 'BackgroundColor', [0.97, 0.97, 0.99], 'BorderType', 'none');

    recordBtn = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', '🎙 START RECORDING', 'FontSize', 14, 'FontWeight', 'bold', 'Units', 'normalized', 'Position', [0.3, 0.2, 0.4, 0.6], 'BackgroundColor', [0.2, 0.7, 0.2], 'ForegroundColor', 'white', 'Callback', @recordCallback);

    statusPanel = uipanel('Parent', parent, 'Units', 'normalized', 'Position', [0.1, 0.42, 0.8, 0.06], 'BackgroundColor', [0.9, 0.9, 0.95], 'BorderType', 'line', 'HighlightColor', [0.8, 0.8, 0.9]);

    statusText = uicontrol('Parent', statusPanel, 'Style', 'text', 'String', '✅ Ready to record your voice', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Units', 'normalized', 'Position', [0.05, 0.1, 0.9, 0.8], 'BackgroundColor', [0.9, 0.9, 0.95], 'ForegroundColor', [0.2, 0.2, 0.6]);

    waveformPanel = uipanel('Parent', parent, 'Units', 'normalized', 'Position', [0.05, 0.05, 0.9, 0.35], 'BackgroundColor', 'white', 'BorderType', 'line', 'HighlightColor', [0.7, 0.7, 0.9]);

    waveformAxes = axes('Parent', waveformPanel, 'Units', 'normalized', 'Position', [0.1, 0.2, 0.85, 0.7], 'Color', [0.98, 0.98, 1.0]);
    title(waveformAxes, '🎵 Voice Waveform Visualization', 'FontSize', 14, 'FontWeight', 'bold');
    xlabel(waveformAxes, 'Time (seconds)', 'FontSize', 11);
    ylabel(waveformAxes, 'Amplitude', 'FontSize', 11);
    grid(waveformAxes, 'on');
    set(waveformAxes, 'GridColor', [0.8, 0.8, 0.9], 'GridAlpha', 0.5);

    function recordCallback(~, ~)
        name = get(nameEdit, 'String');
        duration = str2double(get(durationEdit, 'String'));
        
        if isempty(name)
            errordlg('Please enter your name before recording!', 'Input Required', 'modal');
            return;
        end
        
        if isnan(duration) || duration < 1 || duration > 10
            duration = 3;
            set(durationEdit, 'String', '3');
        end
        
        set(recordBtn, 'String', '🔴 RECORDING...', 'BackgroundColor', [0.8, 0.2, 0.2]);
        set(statusText, 'String', '🎙 Recording in progress... Please speak clearly!');
        drawnow;
        
        fs = 44100;
        nBits = 16;
        recorder = audiorecorder(fs, nBits, 1);
        recordblocking(recorder, duration);
        
        y = getaudiodata(recorder);
        
        set(recordBtn, 'String', '🎙 START RECORDING', 'BackgroundColor', [0.2, 0.7, 0.2]);
        
        if isempty(y) || ~isvector(y)
            set(statusText, 'String', '❌ Recording failed - no audio detected', 'ForegroundColor', [0.8, 0.2, 0.2]);
            return;
        elseif max(abs(y)) < 0.01
            set(statusText, 'String', '⚠ Recording complete - signal is weak, try speaking louder', 'ForegroundColor', [0.8, 0.5, 0.2]);
            warndlg('The recording may be too quiet. Please try again speaking louder.', 'Quality Warning');
        else
            set(statusText, 'String', '✅ Recording complete - excellent quality!', 'ForegroundColor', [0.2, 0.6, 0.2]);
        end
        
        t = linspace(0, duration, length(y));
        plot(waveformAxes, t, y, 'LineWidth', 2, 'Color', [0.2, 0.4, 0.8]);
        xlabel(waveformAxes, 'Time (seconds)', 'FontSize', 11);
        ylabel(waveformAxes, 'Amplitude', 'FontSize', 11);
        title(waveformAxes, sprintf('🎵 Voice Waveform - %s', name), 'FontSize', 14, 'FontWeight', 'bold');
        grid(waveformAxes, 'on');
        set(waveformAxes, 'GridColor', [0.8, 0.8, 0.9], 'GridAlpha', 0.5);
        
        ensure_data_initialized();
        
        features = extract_robust_features(y, fs);
        
        sound_number = sound_number + 1;
        data{sound_number, 1} = features.time_domain;
        data{sound_number, 2} = features.frequency_domain;
        data{sound_number, 3} = features.spectral;
        data{sound_number, 4} = name;
        data{sound_number, 5} = 'Microphone';
        data{sound_number, 6} = mean(y.^2);
        
        sanitized_name = regexprep(name, '[^a-zA-Z0-9]', '_');
        unique_filename = [sanitized_name '_' datestr(now, 'yyyymmddHHMMSS') '.wav'];
        audiowrite(unique_filename, y, fs);
        data{sound_number, 7} = unique_filename;
        
        if exist('name_database.mat', 'file')
            copyfile('name_database.mat', 'name_database_backup.mat');
        end
        
        save('name_database.mat', 'data', 'sound_number', 'fs', 'nBits');
        
        msgbox(sprintf('🎉 Voice successfully added to database!\n\nName: %s\nDuration: %.1f seconds', name, duration), 'Success', 'modal');
    end
end

function setupIdentifyTab(parent)
    global data sound_number;
    
    headerPanel = uipanel('Parent', parent, 'Units', 'normalized', 'Position', [0.05, 0.85, 0.9, 0.1], 'BackgroundColor', [0.2, 0.6, 0.2], 'BorderType', 'none', 'ForegroundColor', 'white');
    
    uicontrol('Parent', headerPanel, 'Style', 'text', 'String', '🔍 Voice Identification System', 'FontSize', 18, 'FontWeight', 'bold', 'Units', 'normalized', 'Position', [0.1, 0.2, 0.8, 0.6], 'BackgroundColor', [0.2, 0.6, 0.2], 'ForegroundColor', 'white');

    controlPanel = uipanel('Parent', parent, 'Units', 'normalized', 'Position', [0.1, 0.7, 0.8, 0.12], 'BackgroundColor', [0.97, 0.99, 0.97], 'BorderType', 'line', 'HighlightColor', [0.7, 0.9, 0.7]);

    recordBtn = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', '🎙 RECORD VOICE', 'FontSize', 14, 'FontWeight', 'bold', 'Units', 'normalized', 'Position', [0.1, 0.3, 0.35, 0.4], 'BackgroundColor', [0.2, 0.6, 0.8], 'ForegroundColor', 'white', 'Callback', @recordAudioCallback);

    identifyBtn = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', '🔍 IDENTIFY SPEAKER', 'FontSize', 14, 'FontWeight', 'bold', 'Units', 'normalized', 'Position', [0.55, 0.3, 0.35, 0.4], 'BackgroundColor', [0.8, 0.4, 0.2], 'ForegroundColor', 'white', 'Callback', @identifyCallback);

    resultPanel = uipanel('Parent', parent, 'Units', 'normalized', 'Position', [0.1, 0.58, 0.8, 0.1], 'BackgroundColor', [0.95, 0.95, 0.99], 'BorderType', 'line', 'HighlightColor', [0.7, 0.9, 0.7]);

    resultText = uicontrol('Parent', resultPanel, 'Style', 'text', 'String', '🎤 Click "Record Voice" to start identification', 'FontSize', 13, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Units', 'normalized', 'Position', [0.05, 0.1, 0.9, 0.8], 'BackgroundColor', [0.95, 0.95, 0.99], 'ForegroundColor', [0.2, 0.2, 0.6]);

    waveformPanel = uipanel('Parent', parent, 'Units', 'normalized', 'Position', [0.05, 0.05, 0.9, 0.5], 'BackgroundColor', 'white', 'BorderType', 'line', 'HighlightColor', [0.7, 0.9, 0.7]);

    waveformAxes = axes('Parent', waveformPanel, 'Units', 'normalized', 'Position', [0.1, 0.15, 0.85, 0.75], 'Color', [0.98, 1.0, 0.98]);
    title(waveformAxes, '🎵 Audio Analysis Waveform', 'FontSize', 14, 'FontWeight', 'bold');
    xlabel(waveformAxes, 'Time (seconds)', 'FontSize', 11);
    ylabel(waveformAxes, 'Amplitude', 'FontSize', 11);
    grid(waveformAxes, 'on');
    set(waveformAxes, 'GridColor', [0.8, 0.9, 0.8], 'GridAlpha', 0.5);

    audioData = [];
    audioFs = 44100;

    function recordAudioCallback(~, ~)
        duration = 3;
        set(recordBtn, 'String', '🔴 RECORDING...', 'BackgroundColor', [0.8, 0.2, 0.2]);
        set(resultText, 'String', '🎙 Recording... Please speak now!');
        drawnow;
        
        recorder = audiorecorder(audioFs, 16, 1);
        recordblocking(recorder, duration);
        audioData = getaudiodata(recorder);
        
        set(recordBtn, 'String', '🎙 RECORD VOICE', 'BackgroundColor', [0.2, 0.6, 0.8]);
        
        t = linspace(0, duration, length(audioData));
        plot(waveformAxes, t, audioData, 'LineWidth', 2, 'Color', [0.2, 0.6, 0.2]);
        title(waveformAxes, '🎵 Recorded Audio for Analysis', 'FontSize', 14, 'FontWeight', 'bold');
        xlabel(waveformAxes, 'Time (seconds)', 'FontSize', 11);
        ylabel(waveformAxes, 'Amplitude', 'FontSize', 11);
        grid(waveformAxes, 'on');
        set(waveformAxes, 'GridColor', [0.8, 0.9, 0.8], 'GridAlpha', 0.5);
        
        set(resultText, 'String', '✅ Recording complete! Click "Identify Speaker" to analyze.');
    end

    function identifyCallback(~, ~)
        if isempty(audioData)
            set(resultText, 'String', '⚠ Please record audio first!', 'ForegroundColor', [0.8, 0.4, 0.2]);
            return;
        end
        
        ensure_data_initialized();
        
        if sound_number == 0
            set(resultText, 'String', '❌ Database is empty! Please add voices first.', 'ForegroundColor', [0.8, 0.2, 0.2]);
            return;
        end
        
        set(resultText, 'String', '🔄 Analyzing voice patterns...', 'ForegroundColor', [0.2, 0.4, 0.8]);
        drawnow;
        
        try
            features = extract_robust_features(audioData, audioFs);
            
            distances = zeros(sound_number, 1);
            for i = 1:sound_number
                dist1 = norm(features.time_domain - data{i, 1});
                dist2 = norm(features.frequency_domain - data{i, 2});
                dist3 = norm(features.spectral - data{i, 3});
                distances(i) = dist1 + dist2 + dist3;
            end
            
            [~, idx] = min(distances);
            identified_name = data{idx, 4};
            confidence = 1 / (1 + distances(idx));
            
            if confidence > 0.7
                result_icon = '✅';
                result_color = [0.2, 0.6, 0.2];
                confidence_text = 'High';
            elseif confidence > 0.5
                result_icon = '⚠';
                result_color = [0.8, 0.5, 0.2];
                confidence_text = 'Medium';
            else
                result_icon = '❓';
                result_color = [0.8, 0.4, 0.4];
                confidence_text = 'Low';
            end
            
            set(resultText, 'String', sprintf('%s Identified: %s | Confidence: %s (%.1f%%)', result_icon, identified_name, confidence_text, confidence * 100), 'ForegroundColor', result_color);
                
        catch err
            set(resultText, 'String', ['❌ Analysis error: ' err.message], 'ForegroundColor', [0.8, 0.2, 0.2]);
        end
    end
end

function setupDatabaseTab(parent)
    global data sound_number;
    
    headerPanel = uipanel('Parent', parent, 'Units', 'normalized', 'Position', [0.05, 0.85, 0.9, 0.1], 'BackgroundColor', [0.6, 0.2, 0.4], 'BorderType', 'none');
    
    uicontrol('Parent', headerPanel, 'Style', 'text', 'String', '📊 Voice Database Management', 'FontSize', 18, 'FontWeight', 'bold', 'Units', 'normalized', 'Position', [0.1, 0.2, 0.8, 0.6], 'BackgroundColor', [0.6, 0.2, 0.4], 'ForegroundColor', 'white');

    tablePanel = uipanel('Parent', parent, 'Units', 'normalized', 'Position', [0.05, 0.35, 0.9, 0.48], 'BackgroundColor', 'white', 'BorderType', 'line', 'HighlightColor', [0.9, 0.7, 0.8]);

    table = uitable('Parent', tablePanel, 'Units', 'normalized', 'Position', [0.02, 0.02, 0.96, 0.96], 'ColumnName', {'ID', 'Name', 'Source', 'Audio File', 'Energy Level'}, 'ColumnEditable', [false, false, false, false, false], 'BackgroundColor', [1.0, 0.98, 0.99; 0.98, 0.96, 0.98], 'FontSize', 10, 'CellSelectionCallback', @tableSelectCallback);

    controlPanel = uipanel('Parent', parent, 'Units', 'normalized', 'Position', [0.05, 0.18, 0.9, 0.15], 'BackgroundColor', [0.99, 0.97, 0.98], 'BorderType', 'line', 'HighlightColor', [0.9, 0.7, 0.8]);

    refreshBtn = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', '🔄 REFRESH', 'FontSize', 12, 'FontWeight', 'bold', 'Units', 'normalized', 'Position', [0.05, 0.3, 0.25, 0.4], 'BackgroundColor', [0.2, 0.6, 0.8], 'ForegroundColor', 'white', 'Callback', @refreshCallback);

    playBtn = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', '▶ PLAY', 'FontSize', 12, 'FontWeight', 'bold', 'Units', 'normalized', 'Position', [0.375, 0.3, 0.25, 0.4], 'BackgroundColor', [0.2, 0.7, 0.2], 'ForegroundColor', 'white', 'Callback', @playCallback);

    deleteBtn = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', '🗑 DELETE', 'FontSize', 12, 'FontWeight', 'bold', 'Units', 'normalized', 'Position', [0.7, 0.3, 0.25, 0.4], 'BackgroundColor', [0.8, 0.2, 0.2], 'ForegroundColor', 'white', 'Callback', @deleteCallback);

    statusPanel = uipanel('Parent', parent, 'Units', 'normalized', 'Position', [0.05, 0.05, 0.9, 0.1], 'BackgroundColor', [0.95, 0.93, 0.95], 'BorderType', 'line', 'HighlightColor', [0.9, 0.7, 0.8]);

    statusText = uicontrol('Parent', statusPanel, 'Style', 'text', 'String', '', 'FontSize', 11, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Units', 'normalized', 'Position', [0.05, 0.2, 0.9, 0.6], 'BackgroundColor', [0.95, 0.93, 0.95], 'ForegroundColor', [0.4, 0.2, 0.3]);

    selectedRow = 0;
    refreshTable();

    function refreshTable()
        try
            ensure_data_initialized();
            
            if exist('name_database.mat', 'file') && sound_number > 0
                tableData = cell(sound_number, 5);
                
                for ii = 1:sound_number
                    if size(data, 2) >= 7
                        tableData{ii, 1} = ii;
                        tableData{ii, 2} = data{ii, 4};
                        tableData{ii, 3} = data{ii, 5};
                        tableData{ii, 4} = data{ii, 7};
                        tableData{ii, 5} = sprintf('%.2e', data{ii, 6});
                    end
                end
                
                set(table, 'Data', tableData);
                set(statusText, 'String', sprintf('📊 Database loaded successfully! Total voices: %d', sound_number), 'ForegroundColor', [0.2, 0.6, 0.2]);
            else
                set(table, 'Data', {});
                set(statusText, 'String', '📂 Database is empty or not found', 'ForegroundColor', [0.8, 0.4, 0.2]);
            end
        catch err
            set(statusText, 'String', ['❌ Error loading database: ' err.message], 'ForegroundColor', [0.8, 0.2, 0.2]);
        end
    end

    function refreshCallback(~, ~)
        refreshTable();
    end

    function tableSelectCallback(~, event)
        if ~isempty(event.Indices)
            selectedRow = event.Indices(1);
            set(statusText, 'String', sprintf('✅ Selected entry #%d for operations', selectedRow), 'ForegroundColor', [0.2, 0.4, 0.8]);
        end
    end

    function playCallback(~, ~)
        if selectedRow == 0 || isempty(selectedRow)
            set(statusText, 'String', '⚠ Please select a database entry first!', 'ForegroundColor', [0.8, 0.4, 0.2]);
            return;
        end
        
        try
            ensure_data_initialized();
            
            if selectedRow > 0 && selectedRow <= sound_number && size(data, 2) >= 7
                filename = data{selectedRow, 7};
                
                if isempty(filename) || ~ischar(filename)
                    set(statusText, 'String', '❌ No audio file associated with this entry', 'ForegroundColor', [0.8, 0.2, 0.2]);
                    return;
                end
                
                if exist(filename, 'file')
                    [y, file_fs] = audioread(filename);
                    clear sound;
                    sound(y, file_fs);
                    set(statusText, 'String', sprintf('▶ Playing: %s', filename), 'ForegroundColor', [0.2, 0.6, 0.2]);
                else
                    [~, name, ~] = fileparts(filename);
                    wav_filename = [name '.wav'];
                    
                    if exist(wav_filename, 'file')
                        [y, file_fs] = audioread(wav_filename);
                        clear sound;
                        sound(y, file_fs);
                        set(statusText, 'String', sprintf('▶ Playing: %s', wav_filename), 'ForegroundColor', [0.2, 0.6, 0.2]);
                    else
                        set(statusText, 'String', sprintf('❌ Audio file not found: %s', filename), 'ForegroundColor', [0.8, 0.2, 0.2]);
                        
                        wav_files = dir('*.wav');
                        if ~isempty(wav_files)
                            fprintf('Available .wav files in current directory:\n');
                            for i = 1:length(wav_files)
                                fprintf('  %s\n', wav_files(i).name);
                            end
                        end
                    end
                end
            else
                set(statusText, 'String', '❌ Invalid selection or corrupted database entry', 'ForegroundColor', [0.8, 0.2, 0.2]);
            end
        catch err
            set(statusText, 'String', ['❌ Playback error: ' err.message], 'ForegroundColor', [0.8, 0.2, 0.2]);
            fprintf('Detailed error: %s\n', getReport(err));
        end
    end

    function deleteCallback(~, ~)
        if selectedRow == 0
            set(statusText, 'String', '⚠ Please select a database entry first!', 'ForegroundColor', [0.8, 0.4, 0.2]);
            return;
        end
        
        answer = questdlg('Are you sure you want to permanently delete this voice entry?', 'Confirm Deletion', 'Yes, Delete', 'Cancel', 'Cancel');
        
        if strcmp(answer, 'Yes, Delete')
            try
                if selectedRow > 0 && selectedRow <= sound_number && size(data, 2) >= 7
                    filename = data{selectedRow, 7};
                    if exist(filename, 'file')
                        delete(filename);
                    end
                    
                    data(selectedRow, :) = [];
                    sound_number = sound_number - 1;
                    
                    if exist('name_database.mat', 'file')
                        copyfile('name_database.mat', 'name_database_backup.mat');
                    end
                    
                    if exist('fs', 'var') && exist('nBits', 'var')
                        save('name_database.mat', 'data', 'sound_number','fs', 'nBits');
                    else
                        save('name_database.mat', 'data', 'sound_number');
                    end
                    
                    refreshTable();
                    selectedRow = 0;
                    set(statusText, 'String', '✅ Entry deleted successfully!', 'ForegroundColor', [0.2, 0.6, 0.2]);
                else
                    set(statusText, 'String', '❌ Invalid selection for deletion', 'ForegroundColor', [0.8, 0.2, 0.2]);
                end
            catch err
                if exist('name_database_backup.mat', 'file')
                    copyfile('name_database_backup.mat', 'name_database.mat');
                end
                set(statusText, 'String', ['❌ Deletion error: ' err.message], 'ForegroundColor', [0.8, 0.2, 0.2]);
            end
        end
    end
end

function ensure_data_initialized()
    global data sound_number fs nBits;
    
    if exist('name_database.mat', 'file')
        load('name_database.mat', 'data', 'sound_number', 'fs', 'nBits');
    else
        data = {};
        sound_number = 0;
        fs = 44100;
        nBits = 16;
    end
end

function features = extract_robust_features(signal, fs)
    signal_norm = (signal - mean(signal)) / std(signal);
    
    frame_length = round(0.025 * fs);
    hop_length = round(0.01 * fs);
    num_frames = floor((length(signal) - frame_length) / hop_length) + 1;
    
    pitch_values = zeros(num_frames, 1);
    for i = 1:num_frames
        start_idx = (i-1) * hop_length + 1;
        end_idx = start_idx + frame_length - 1;
        frame = signal_norm(start_idx:end_idx);
        autocorr = xcorr(frame, frame);
        autocorr = autocorr(frame_length:end);
        min_period = round(fs / 800);
        max_period = round(fs / 50);
        if max_period <= length(autocorr)
            [~, peak_idx] = max(autocorr(min_period:max_period));
            period = peak_idx + min_period - 1;
            pitch_values(i) = fs / period;
        end
    end
    
    valid_pitch = pitch_values(pitch_values > 0);
    if isempty(valid_pitch)
        features.time_domain = [0; 0; 0; 0; 0];
    else
        features.time_domain = [mean(valid_pitch); std(valid_pitch); median(valid_pitch); min(valid_pitch); max(valid_pitch)];
    end
    
    N = length(signal);
    max_freq_bins = min(512, N);
    Y = zeros(max_freq_bins, 1);
    for k = 0:max_freq_bins-1
        sum_real = 0;
        sum_imag = 0;
        for n = 0:N-1
            angle = -2 * pi * k * n / N;
            sum_real = sum_real + signal(n+1) * cos(angle);
            sum_imag = sum_imag + signal(n+1) * sin(angle);
        end
        Y(k+1) = sum_real + 1i * sum_imag;
    end
    
    P = abs(Y/N);
    P(2:end-1) = 2*P(2:end-1);
    
    features.frequency_domain = [mean(P); std(P); max(P); sum(P)];
    
    features.spectral = [mean(signal_norm.^2); sum(abs(diff(signal_norm)))];
end