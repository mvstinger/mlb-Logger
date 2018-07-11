classdef Logger < Singleton

    properties(Constant)
        LVL_DEBUG = 0;
        LVL_INFO = 1;
        LVL_WARNING = 2;
        LVL_ERROR = 3;
        LVL_CRITICAL = 4;
    end % properties
    
    properties(Access=public)
        filename_format = 'LOG_YYYYmmdd_HHMMSS.txt';
        log_msg_format = '%DTT% [%LVL%] (%FXN%:%LIN%)\t %MSG%';
        output_FID = nan;
        level = Logger.LVL_INFO;
    end % properties
    
    
    methods(Static)
        function obj = instance(varargin)
            persistent singleton_instance;
            if isempty(singleton_instance)
                obj = Logger(varargin{:});
                singleton_instance = obj;
            else
                obj = singleton_instance;
            end
        end % function
    end % methods
    
    
    methods(Access=private)
        % Constructors
        function obj = Logger(varargin)
            if nargin==1
                % If a directory is provided, write to that directory with
                %   formatted filename
                % If a full filename is provided, write to that file(path)
                [aux_fp, aux_fn, aux_ext] = fileparts(varargin{1});
                aux_fn = [aux_fn, aux_ext];
                if isempty(aux_fn)
                    filename = datestr(now(), obj.filename_format);
                else
                    filename = aux_fn;
                end
                file_path = fullfile(aux_fp, filename);
            else % No arguments to constructor (or .instance())
                % If nothing is provided, write to the current directory
                %   with a formatted filename
                file_path = datestr(now(), obj.filename_format);
            end % if nargin
            %   Open file for writing
            obj.output_FID = fopen(file_path, 'w+');
            %   Handle error
            if obj.output_FID == -1
                warning('Unable to open file %s. Attempting to open in current directory...', file_path);
                if nargin==1
                    file_path = fullfile('.', filename);
                else
                    file_path = fullfile('.', datestr(now(), obj.filename_format));
                end
                %   Open file for writing
                obj.output_FID = fopen(file_path, 'w+');
                if obj.output_FID == -1
                    error('Unable to open file %s.', file_path);
                end
            end 
        end % function
    
        function this_line = __insert_subs(obj, lvl, msg)
          stack_data = dbstack(1);
          this_line = strrep(obj.log_msg_format, '%DTT%', datestr(now(), 'YYYY-mm-dd HH:MM:SS'));
          this_line = strrep(this_line, '%LVL%', lvl);
          this_line = strrep(this_line, '%MSG%', msg);
          this_line = strrep(this_line, '%FXN%', stack_data(1).file);
          this_line = strrep(this_line, '%LIN%', num2str(stack_data(1).line));
        end % function
    
        function __write_msg(obj, msg, varargin)
            fprintf(obj.output_FID, [msg, '\n'], varargin{:});
        end % function
    end % methods

    methods(Access=public)
        %   Destructor
        function delete(obj)
            fclose(obj.output_FID);
        end % function
        
        %   Logging commands
        function DEBUG(obj, msg, varargin)
            if obj.level <= Logger.LVL_DEBUG
              this_line = obj.__insert_subs(' DEBUG    ', msg);
              obj.__write_msg(this_line, varargin{:});
            end % if
        end % function
        
        function INFO(obj, msg, varargin)
            if obj.level <= Logger.LVL_INFO
                stack_data = dbstack(1);
                this_line = strrep(obj.log_msg_format, '%DTT%', datestr(now(), 'YYYY-mm-dd HH:MM:SS'));
                this_line = strrep(this_line, '%LVL%', ' INFO     ');
                this_line = strrep(this_line, '%MSG%', msg);
                this_line = strrep(this_line, '%FXN%', stack_data(1).file);
                this_line = strrep(this_line, '%LIN%', num2str(stack_data(1).line));
                this_line = sprintf(this_line, varargin{:});
                obj.__write_msg(this_line);
            end % if
        end % function
        
        function WARNING(obj, msg, varargin)
            if obj.level <= Logger.LVL_WARNING
                stack_data = dbstack(1);
                this_line = strrep(obj.log_msg_format, '%DTT%', datestr(now(), 'YYYY-mm-dd HH:MM:SS'));
                this_line = strrep(this_line, '%LVL%', ' WARNING  ');
                this_line = strrep(this_line, '%MSG%', msg);
                this_line = strrep(this_line, '%FXN%', stack_data(1).file);
                this_line = strrep(this_line, '%LIN%', num2str(stack_data(1).line));
                this_line = sprintf(this_line, varargin{:});
                obj.__write_msg(this_line);
            end % if
        end % function
        
        function ERROR(obj, msg, varargin)
            if obj.level <= Logger.LVL_ERROR
                stack_data = dbstack(1);
                this_line = strrep(obj.log_msg_format, '%DTT%', datestr(now(), 'YYYY-mm-dd HH:MM:SS'));
                this_line = strrep(this_line, '%LVL%', ' ERROR    ');
                this_line = strrep(this_line, '%MSG%', msg);
                this_line = strrep(this_line, '%FXN%', stack_data(1).file);
                this_line = strrep(this_line, '%LIN%', num2str(stack_data(1).line));
                this_line = sprintf(this_line, varargin{:});
                obj.__write_msg(this_line);
            end % if
        end % function
        
        function CRITICAL(obj, msg, varargin)
            if obj.level <= Logger.LVL_CRITICAL
                stack_data = dbstack(1);
                this_line = strrep(obj.log_msg_format, '%DTT%', datestr(now(), 'YYYY-mm-dd HH:MM:SS'));
                this_line = strrep(this_line, '%LVL%', ' CRITICAL ');
                this_line = strrep(this_line, '%MSG%', msg);
                this_line = strrep(this_line, '%FXN%', stack_data(1).file);
                this_line = strrep(this_line, '%LIN%', num2str(stack_data(1).line));
                this_line = sprintf(this_line, varargin{:});
                obj.__write_msg(this_line);
            end % if
        end % function
    end % methods

end % classdef
