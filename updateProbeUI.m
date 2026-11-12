function [probeConfirmed, isDualProbe] = updateProbeUI(isWaiting, isBlue)
    persistent fig lb lastBlue confirmed dualFlag
    
    if isempty(lastBlue)
        lastBlue = uint8(255);
        confirmed = uint8(0);
        dualFlag = uint8(0);
    end
    
    if isWaiting
        if isempty(fig) || ~isvalid(fig)
            confirmed = uint8(0);
            fig = uifigure('Name', 'Выбор ПЭП', 'Position', [500 500 220 180]);
            
            if isBlue == 1
                items = {'A5', 'A10'};
                dualFlag = uint8(1);
            else
                items = {'S2C', 'S5C'};
                dualFlag = uint8(0);
            end
            
            lb = uilistbox(fig, 'Position', [20 60 180 100], 'Items', items);
            uibutton(fig, 'Text', 'OK', 'Position', [60 20 100 30], ...
                'ButtonPushedFcn', @(~,~) onOkClick());
            
            lastBlue = isBlue;
            drawnow;
        end
        
        if isvalid(fig) && (isBlue ~= lastBlue)
            if isBlue == 1
                lb.Items = {'A5', 'A10'};
                dualFlag = uint8(1);
            else
                lb.Items = {'S2C', 'S5C'};
                dualFlag = uint8(0);
            end
            lastBlue = isBlue;
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
        confirmed = uint8(0);
        lastBlue = uint8(255);
    end
    
    probeConfirmed = uint8(confirmed);
    isDualProbe = uint8(dualFlag);

    function onOkClick()
        confirmed = uint8(1);
    end
end