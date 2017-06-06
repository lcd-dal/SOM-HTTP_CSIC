% SAVEF Save current figure in .fig and .png formats, decide by modef, with
% name

function savef( modef, name )

if modef
    saveas(gcf,name,'fig');
    saveas(gcf,name,'png');
end

end
