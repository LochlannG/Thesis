function keys = setupKeys()
    keys = struct();
    keys.escape = KbName('ESCAPE');
    keys.enter  = KbName('return');
    keys.lt = KbName('LeftArrow');
    keys.rt = KbName('RightArrow');
    keys.dw = KbName('DownArrow');
    keys.up = KbName('UpArrow');

end