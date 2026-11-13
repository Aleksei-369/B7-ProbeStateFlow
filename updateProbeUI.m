function [probeConfirmed, isDualProbe] = updateProbeUI(isWaiting, isBlue)
    persistent fig tbl lastBlue confirmed dualFlag disabledStyle
    
    if isempty(lastBlue)
        lastBlue = uint8(255);
        confirmed = uint8(0);
        dualFlag = uint8(0);
    end
    
    if isWaiting
        % 1. Создаем окно с сеткой и таблицей один раз при входе в состояние
        if isempty(fig) || ~isvalid(fig)
            confirmed = uint8(0);
            fig = uifigure('Name', 'Выбор ПЭП', 'Position', [500 500 320 230]);
            
            % Адаптивная сетка: 2 строки (таблица + кнопка) x 1 колонка
            gl = uigridlayout(fig, [2, 1]);
            gl.RowHeight = {'1x', 35};
            gl.Padding = [15 15 15 15];
            gl.RowSpacing = 10;
            
            % Стиль для задизейбленных строк (светло-серый фон и бледный текст)
            disabledStyle = uistyle('FontColor', [0.65 0.65 0.65], ...
                                    'BackgroundColor', [0.95 0.95 0.95]);
            
            % Данные таблицы: всегда полный парк из 4 датчиков
            probeData = {
                'A5',  'Р/С (Dual)',      '5 МГц';
                'A10', 'Р/С (Dual)',      '10 МГц';
                'S2C', 'Совм. (Single)',  '2.25 МГц';
                'S5C', 'Совм. (Single)',  '5 МГц'
            };
            
            % Создаем таблицу с выделением целой строки
            tbl = uitable(gl, 'Data', probeData, ...
                'ColumnName', {'Датчик', 'Тип', 'Частота'}, ...
                'RowName', {}, ...
                'ColumnWidth', {'fit', 'fit', 'fit'}, ...
                'SelectionType', 'row', ...
                'Multiselect', 'off', ...
                'SelectionChangedFcn', @(src, event) onRowSelected(src, event));
            tbl.Layout.Row = 1;
            tbl.Layout.Column = 1;
            
            % Кнопка подтверждения выбора
            btnOk = uibutton(gl, 'Text', 'Подтвердить (ОК)', 'FontWeight', 'bold', ...
                'ButtonPushedFcn', @(~, ~) onOkClick());
            btnOk.Layout.Row = 2;
            btnOk.Layout.Column = 1;
            
            lastBlue = uint8(255); % Принудительное обновление при открытии
        end
        
        % 2. Динамически дизейблим неподходящие строки при изменении синего разъема
        if isvalid(fig) && (isBlue ~= lastBlue)
            removeStyle(tbl);
            
            if isBlue == 1
                % Подключен синий порт -> доступны строки 1-2 (A5, A10), заблокированы 3-4
                addStyle(tbl, disabledStyle, 'row', [3 4]);
                if isempty(tbl.Selection) || tbl.Selection > 2
                    tbl.Selection = 1; % Выделяем A5 по умолчанию
                end
                dualFlag = uint8(1);
            else
                % Синий порт пуст -> доступны строки 3-4 (S2C, S5C), заблокированы 1-2
                addStyle(tbl, disabledStyle, 'row', [1 2]);
                if isempty(tbl.Selection) || tbl.Selection < 3
                    tbl.Selection = 3; % Выделяем S2C по умолчанию
                end
                dualFlag = uint8(0);
            end
            
            lastBlue = isBlue;
            drawnow;
        end
        
        % Аварийное подтверждение, если окно закрыли крестиком
        if ~isvalid(fig)
            confirmed = uint8(1);
        end
        
    else
        % 3. Чарт вышел из режима ожидания -> закрываем окно
        if ~isempty(fig) && isvalid(fig)
            close(fig);
            drawnow;
        end
        confirmed = uint8(0);
        lastBlue = uint8(255);
    end
    
    probeConfirmed = uint8(confirmed);
    isDualProbe = uint8(dualFlag);

    % Блокируем выбор серых (недоступных) строк при клике мышкой
    function onRowSelected(src, event)
        if isempty(event.Selection)
            return;
        end
        row = event.Selection(1);
        if lastBlue == 1 && row > 2
            src.Selection = 1; % Возвращаем на A5
        elseif lastBlue == 0 && row < 3
            src.Selection = 3; % Возвращаем на S2C
        end
    end

    function onOkClick()
        confirmed = uint8(1);
    end
end