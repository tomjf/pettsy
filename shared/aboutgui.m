 function aboutgui

%creates a dialog box with information about PeTTSy


fig = dialog('Name', 'About PeTTSy');

%size it in cm and centre it on screen
set(0,'Units','centimeters')
screen_size = get(0,'ScreenSize');
figwidth = 13;
figheight = 7;
figbottom = (screen_size(4)-figheight)/2;
figleft = (screen_size(3)-figwidth)/2;
%allow for tip window

pos = [figleft figbottom figwidth figheight];
set(fig, 'Units', 'centimeters', 'Position', pos);

okButton = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[figwidth-2.25 0.25 2 0.7], ...
        'string', 'OK', ...
        'Parent',fig, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','close(gcf)');
   
    titleStr = '<html><body style="font-family:''sans serif''"><span style="font-size:14px;font-weight:bold">PeTTSy</span><span style="font-size:12px">, Perturbation Theory Toolbox for Systems</span><br/><br/><span style="font-size:11px"><i>Mirela Domijan, Paul Brown, Boris Shulgin & David Rand</i><br/>&copy; 2015 University of Warwick<br/>';
    
    titleStr = [titleStr '<br/>Release 1.0.2, September 2017<br/><br/>This software is distributed freely and without warranty under the terms of the <a href="http://www.gnu.org/licenses/gpl-3.0.en.html">GNU General Public License</a></span></body></html>'];
    
    labelpos_cm = [0.5 1.5 figwidth-1 figheight-1.75];
    [hLabel, ~] = create_html_panel(fig, labelpos_cm, titleStr, false);
   
   
   
   
    


