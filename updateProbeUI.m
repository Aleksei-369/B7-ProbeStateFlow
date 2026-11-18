function [probeConfirmed, isDualProbe] = updateProbeUI(isWaitingSingle, isZeroAdjust)
    persistent fig confirmed dualFlag modalShown lastState
    
    if isempty(confirmed)
        confirmed = uint8(0);
        dualFlag = uint8(0);
        modalShown = false;
        lastState = [uint8(255), uint8(255)];
    end
    
    % Быстрый выход без перерисовки, если состояния не менялись
    currState = [uint8(isWaitingSingle), uint8(isZeroAdjust)];
    if isequal(currState, lastState) && (confirmed == 0) && ~isempty(fig) && isvalid(fig)
        probeConfirmed = uint8(0);
        isDualProbe = uint8(dualFlag);
        return;
    end
    lastState = currState;
    
    % --- ВЕТКА 1: МОДАЛЬНОЕ ПОДТВЕРЖДЕНИЕ В PE_ZeroGainAdjust ---
    if isZeroAdjust && ~modalShown
        modalShown = true;
        
        if ~isempty(fig) && isvalid(fig)
            close(fig);
            drawnow;
        end
        
        detectedProbe = 'A5';
        msg = sprintf('Автоматически определен датчик: %s.\nПодтвердить выбор?', detectedProbe);
        answer = questdlg(msg, 'Автоопределение ПЭП', 'Да', 'Нет', 'Да');
        
        if strcmp(answer, 'Да') || isempty(answer)
            confirmed = uint8(1);
            dualFlag = uint8(1);
        else
            showDualModalTable();
            dualFlag = uint8(1);
            confirmed = uint8(1);
        end
    end
    
    if ~isZeroAdjust
        modalShown = false;
    end

    % --- ВЕТКА 2: НЕМОДАЛЬНАЯ ТАБЛИЦА СОВМЕЩЕННЫХ ПЭП ---
    if isWaitingSingle && ~isZeroAdjust
        if isempty(fig) || ~isvalid(fig)
            confirmed = uint8(0);
            dualFlag = uint8(0);
            
            fig = uifigure('Name', 'Выбор совмещенного ПЭП', 'Position', [500 500 280 185]);
            
            gl = uigridlayout(fig, [2, 1]);
            gl.RowHeight = {'1x', 35};
            gl.Padding = [15 15 15 15];
            gl.RowSpacing = 10;
            
            singleData = {
                'S2C', 'Совм. (Single)', '2.25 МГц';
                'S5C', 'Совм. (Single)', '5 МГц'
            };
            
            tbl = uitable(gl, 'Data', singleData, ...
                'ColumnName', {'Датчик', 'Тип', 'Частота'}, ...
                'RowName', {}, ...
                'ColumnWidth', {'1x', '2x', '1x'}, ...
                'SelectionType', 'row', ...
                'Multiselect', 'off');
            tbl.Selection = 1;
            tbl.Layout.Row = 1;
            tbl.Layout.Column = 1;
            
            btnOk = uibutton(gl, 'Text', 'Подтвердить (ОК)', 'FontWeight', 'bold', ...
                'ButtonPushedFcn', @(~, ~) onOkClick());
            btnOk.Layout.Row = 2;
            btnOk.Layout.Column = 1;
            
            drawnow;
        end
        
        if ~isvalid(fig)
            confirmed = uint8(1);
        end
    else
        if ~isempty(fig) && isvalid(fig)
            close(fig);
            drawnow;
        end
        if ~isZeroAdjust
            confirmed = uint8(0);
        end
    end
    
    probeConfirmed = uint8(confirmed);
    isDualProbe = uint8(dualFlag);

    function onOkClick()
        confirmed = uint8(1);
    end
end

function showDualModalTable()
    mFig = uifigure('Name', 'Выбор Р/С ПЭП', 'Position', [520 520 280 185], 'WindowStyle', 'modal');
    
    gl = uigridlayout(mFig, [2, 1]);
    gl.RowHeight = {'1x', 35};
    gl.Padding = [15 15 15 15];
    gl.RowSpacing = 10;
    
    dualData = {
        'A5',  'Р/С (Dual)', '5 МГц';
        'A10', 'Р/С (Dual)', '10 МГц'
    };
    
    mTbl = uitable(gl, 'Data', dualData, ...
        'ColumnName', {'Датчик', 'Тип', 'Частота'}, ...
        'RowName', {}, ...
        'ColumnWidth', {'1x', '2x', '1x'}, ...
        'SelectionType', 'row', ...
        'Multiselect', 'off');
    mTbl.Selection = 1;
    mTbl.Layout.Row = 1;
    mTbl.Layout.Column = 1;
    
    btnOk = uibutton(gl, 'Text', 'Выбрать (ОК)', 'FontWeight', 'bold', ...
        'ButtonPushedFcn', @(~, ~) uiresume(mFig));
    btnOk.Layout.Row = 2;
    btnOk.Layout.Column = 1;
    
    uiwait(mFig);
    
    if isvalid(mFig)
        close(mFig);
        drawnow;
    end
end