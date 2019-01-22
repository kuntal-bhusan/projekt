#!/usr/bin/perl

use Tk;
use Tk::AbstractCanvas;
use Data::Dumper;
use Math::Trig;

require Tk::GraphItems;
require Tk::Dialog;

$os = 'win' unless $^O;
$os = 'win' if $^O =~ /win/i;
$os = 'unix' if $^O =~ /linux|unix|aix|sun|solaris|cygwin/i;

print "\nOS : $os\n\n";

my $mw=MainWindow->new(-title=>'proJeKt');

########################################################################################################### THEME
$mw->optionAdd("*font", "-*-verdana-normal-r-*-*-*-110-*-*-*-*-*-*");
$mw->optionAdd('*borderWidth' => 1);
#$mw->optionAdd('*background' => '#F5DEB3');   ## Selecting the color theme
$mw->optionAdd( '*Entry.background',   'snow1' );
$mw->optionAdd( '*Text.background',    'snow1' );

########################################################################################################### THEME



my $w = $mw->screenwidth;
my $h = $mw->screenheight;
$mw->geometry( $w."x".$h);
$mw->resizable(1,1);


########################################################################################################### VARIABLES
my %ball = ();
my %canon = ();
my %power = ();
my %pad = ();
my %arrow = ();
my %wind_can = ();
my %level = ();




## start position

my $initial_height = 300;
my $Y = $initial_height; 
my $X = 0;

## upper boundary
my $upper_X = $w +10; ## left x bound
my $upper_Y = $h + 5; ## left Y boundary

my $upper_XR = 0 - 10; ## right x bound
my $upper_YR = 0 - 5; ## right y bound

##lower boundary

my $lower_X = 0 - 10;
my $lower_Y = 0 - 5;

## pad values
my ($R1, $R2, $R3,$R4,$B1, $B2, $B3,$B4,$G1, $G2, $G3,$G4) = (0,0,0,0,0,0,0,0,0,0,0,0);

my $ball_diameter = 20;
my $ball_radius = $ball_diameter/2;

## other variables
my $angle_deg = 45;  ## initial angle
my $speed = 100;  ## initial velocity
my $acceleration = 2;
my $gravity = 10;
my $time = 0;

my $bounce_speed = 0;
my $bounce_angle = 0;

my $wind = 0; ## initialize randomly (-50 to +50)

my $tank_length = 100;

my $cindex = 1; # canon launch positions
my $bindex = 1; # ball count
my $level = 1;
my $entry_score = 0;
my $score = 0;
my $fire_count = 1;




########################################################################################################### LEVEL DESIGN
########################################################################################################### 
###########################################################################################################


my %level = ();
my $total_levels = 3;


## pads
$level{'1'}{'pad'} = [$w - 50,0,$w - 10,40,$w - 120,0,$w - 80,40,$w - 230,0,$w - 190,40]; 
$level{'2'}{'pad'} = [$w - 50,0,$w - 10,40,$w - 80,$h - 40,$w - 40,$h,$w - 130,$h - 600,$w - 90,$h - 560]; 
$level{'3'}{'pad'} = [$w - 200,$h-70,$w - 160,$h-30,$w-40,250,$w,210,$w - 350,$h - 400,$w - 310,$h - 360]; 


## obstacles

my %obstacle_coords_1 = ();
my %obstacle_coords_2 = ();
my %obstacle_coords_3 = ();
my %obstacle_coords_4 = ();


my ($x1,$y1,$x2,$y2) = (0,$h+40,0,0);

my $obstacle_h_distance = $w/2;
my $obstacle_height = 5;
my $obstacle_width = 100;
my $gapping = 80;
my $buffer = 10;


foreach $i (0 .. 8)
{
my $lbound = $w/4;
my $rbound = $lbound - ($w/2);
my $range = abs($lbound - $rbound);

my $random_h = $lbound + int(rand($range));

$x1 = $w - $random_h;
$y1 = $y1 - $gapping;

$x2 = $x1 - $obstacle_width;
$y2 = $y1 - $obstacle_height;

$obstacle_coords_1{$i} = [$x1,$y1,$x2,$y2];
$obstacle_coords_2{$i} = [$x1,$y2,$x2,$y2-$obstacle_height];

$obstacle_coords_3{$i} = [$x2,$y1+$obstacle_height,$x2,$y2-$obstacle_height*2];
$obstacle_coords_4{$i} = [$x1,$y1+$obstacle_height,$x1,$y2-$obstacle_height*2];

}

########################################################################################################### 
########################################################################################################### 
########################################################################################################### LEVEL DESIGN








########################################################################################################### VARIABLES



my $menu_Frame = $mw -> Frame ( -borderwidth=>3, -relief=>'raised' ) -> pack(-anchor=>'nw', -side=>'top', -fill=>'x');
my $w_Button_about = $menu_Frame -> Button ( -text=>' About ', -relief=>'flat') -> pack(-anchor=>'w', -side=>'right', -padx=>2);
$w_Button_about->configure(-command => \&about);

$menu_Frame -> Label ( -text=>' Level ', -foreground => 'red', -font =>"Courier 12 bold" ) -> pack(-anchor=>'w', -side=>'left', -padx=>2);
$menu_Frame -> Label ( -textvariable => \$level, -borderwidth=>2, -relief=>'sunken', -background=>'white', -font=>'verdana 15') -> pack(-anchor=>'nw', -side=>'left');

$menu_Frame -> Label ( -text=>' Score ', -foreground => 'red', -font =>"Courier 12 bold" ) -> pack(-anchor=>'w', -side=>'left', -padx=>2);
$menu_Frame -> Label ( -textvariable => \$score, -borderwidth=>2, -relief=>'sunken', -background=>'white', -font=>'verdana 15') -> pack(-anchor=>'nw', -side=>'left');

#$menu_Frame -> Label ( -text=>' Wind ', -foreground => 'red', -font =>"Courier 12 bold" ) -> pack(-anchor=>'w', -side=>'left', -padx=>2);
#$menu_Frame -> Label ( -textvariable => \$wind, -borderwidth=>2, -relief=>'sunken', -background=>'white', -font=>'verdana 15') -> pack(-anchor=>'nw', -side=>'left');

$menu_Frame -> Label ( -text=>' You have to hit ', -foreground => 'red', -font =>"Courier 12 bold" ) -> pack(-anchor=>'w', -side=>'left', -padx=>2);
my $turn_color = $menu_Frame -> Label ( -text =>'  ',  -borderwidth=>2, -relief=>'sunken', -background=>'red', -font=>'verdana 15') -> pack(-anchor=>'nw', -side=>'left');




my $scrolled_can = $mw -> Scrolled('AbstractCanvas',-background => 'white')->pack(-fill   => 'both',-expand => 1);
my $can = $scrolled_can->Subwidget('abstractcanvas');



init_canvas($can);
fit_to_canvas();



$message = "";
my $Message_Frame = $mw -> Frame ( -relief=>'raised' ) -> pack(-anchor=>'s', -side=>'bottom', -fill=>'x', -ipady=>2);
my $status_message = $Message_Frame -> Label ( -textvariable => \$message, -borderwidth=>1, -relief=>'flat', -background=>'white', -font=>'verdana 8') -> pack(-anchor=>'nw', -side=>'right');

my $min_speed = 50;
my $max_speed = 200;
my $min_angle = 0;
my $max_angle = 90;


my $Control_Frame = $mw -> Frame ( -relief=>'raised' ) -> pack(-anchor=>'s', -side=>'bottom', -fill=>'x', -padx=>2);


my $scl_velocity = $Control_Frame -> Scale(-bg=>'grey',-label =>'Set speed',
-orient=>'h', -digit=>0,
-from=>$min_speed, -to=>$max_speed,
-length => 5,
-variable=>\$speed, )-> pack(-side=>'left', -padx=>2, -fill => 'x',-expand => 1);

my $scl_angle = $Control_Frame -> Scale(-bg=>'grey',-label =>'Set angle',
-orient=>'h', -digit=>0,
-from=>$min_angle, -to=>$max_angle,
-length => 5,
-variable=>\$angle_deg, )-> pack(-side=>'left', -padx=>2, -fill => 'x',-expand => 1);

my $scl_height = $Control_Frame -> Scale(-bg=>'grey',-label =>'Set height',
-orient=>'h', -digit=>0,
-from=>0, -to=>$h,
-length => 5,
-variable=>\$Y, )-> pack(-side=>'left', -padx=>2, -fill => 'x',-expand => 1);

my $Button_fire = $Control_Frame -> Button ( -text=>'          Fire          ', 
-relief=>'raised', -background => 'lightblue',-activebackground =>'orange',-borderwidth=>1) -> pack(-side=>'right',-fill => 'y',);
$Button_fire->configure(-command => \&fire_canon);


$scl_angle->configure(-command => \&incline_canon);
$scl_velocity->configure(-command => \&incline_canon);
$scl_height->configure(-command => \&incline_canon);


$mw->bind('AbstractCanvas',    '<Up>' => '');
$mw->bind('AbstractCanvas',  '<Down>' => '');
$mw->bind('AbstractCanvas',  '<Left>' => '');
$mw->bind('AbstractCanvas', '<Right>' => '');


$can -> CanvasBind('<Right>',sub { increase_speed(); }); 
$can -> CanvasBind('<Left>',sub { decrease_speed(); }); 
$can -> CanvasBind('<Up>',sub { increase_angle(); }); 
$can -> CanvasBind('<Down>',sub { decrease_angle(); }); 

$can -> CanvasBind('<Key-space>',sub { fire_canon(); }); 

about();

MainLoop; 
();






##########################################################################################################################################
 ### 												SUBROUTINES   																##########
##########################################################################################################################################


sub about
{
my $db = $mw->DialogBox(-title => '', -buttons => ['Ok'], 
                     -default_button => 'Ok');
$db->add('Label',-text => "\nThe proJeKt Game : version 2",-width => 70,-font =>"Courier 18 bold")->pack;

$db->add('Label', -text => "\nInstructions\n
  The objective of the game is to project and hit the balls on the 
  small squares of matching colors. A player will get 2 chances to 
  project each color ball. If the ball hits the correct target, the
  score increases by 1. A minimum score of 3 is required to enter 
  each level.                                                      " ,
-width => 70,-font =>"Courier 12 bold")->pack;

$db->add('Label', -text => "\nDeveloped by\n
Kuntal Kumar Bhusan\nMail to : kuntal.bhusan\@gmail.com\n\n" , -width => 70,-font =>"Courier 12 bold")->pack;

$db->Show();

}




sub increase_speed 
{ 
if($speed > $max_speed) { $speed = $max_speed; incline_canon();}
if($speed < $min_speed) { $speed = $min_speed; incline_canon();}

if($speed > $min_speed && $speed < $max_speed) { $speed += 1; incline_canon();} 
if($speed == $min_speed) { $speed += 1; incline_canon(); }
}

sub decrease_speed 
{ 
if($speed > $max_speed) { $speed = $max_speed; incline_canon();}
if($speed < $min_speed) { $speed = $min_speed; incline_canon();}

if($speed > $min_speed && $speed < $max_speed) { $speed -= 1; incline_canon();} 
if($speed == $max_speed) { $speed -= 1; incline_canon(); } 
}

sub increase_angle 
{ 
if($angle_deg > $max_angle) { $angle_deg = $max_angle; incline_canon();}
if($angle_deg < $min_angle) { $angle_deg = $min_angle; incline_canon();}

if($angle_deg > $min_angle && $angle_deg < $max_angle) { $angle_deg += 1; incline_canon();} 
if($angle_deg == $min_angle) { $angle_deg += 1; incline_canon(); } 
}

sub decrease_angle 
{ 
if($angle_deg > $max_angle) { $angle_deg = $max_angle; incline_canon();}
if($angle_deg < $min_angle) { $angle_deg = $min_angle; incline_canon();}

if($angle_deg > $min_angle && $angle_deg < $max_angle) { $angle_deg -= 1; incline_canon();} 
if($angle_deg == $max_angle) { $angle_deg -= 1; incline_canon(); } 
}



sub init_canvas{
my ($can) = @_;


$can->createLine( $lower_X, $lower_Y,$lower_X,$upper_Y,-fill  => 'black', );
$can->createLine( $lower_X, $upper_Y,$upper_X,$upper_Y,-fill  => 'black', );
$can->createLine( $upper_X,$upper_Y,$upper_X,$lower_Y,-fill  => 'black', );
$can->createLine( $upper_X,$lower_Y,$lower_X, $lower_Y,-fill  => 'black', );

#$sun = $can->createOval($upper_X, $upper_Y, $upper_X + 50, $upper_Y +50, -fill => 'yellow', -tags => ['dummy']);      ## dummy dot

$ball{$bindex} = Tk::GraphItems::Circle->new(canvas=>$can,colour=>'red','x'=> $X,'y'=> $Y, size => $ball_diameter);
$turn_color->configure(-background=>'red');

## initialize wind arrow

#$wind_can{'name'} = $can->createText( $lower_X + 40, $upper_Y - 30 ,-text  => 'wind') ;
#$wind_can{'arrow'} = $can->createLine( $lower_X + 10, $upper_Y - 50 ,$lower_X + 80,$upper_Y - 50,-fill  => 'blue', -width => 4,-arrow =>'last',) ;
#$wind_can{'val'} = $can->Label(-textvariable => \$wind,-background=>'white'); $wind_can{'win'} = $can->createWindow($lower_X + 40, $upper_Y - 70, -window => $wind_can{'val'});

init_pads('1'); ## initialize pads at level 1

}# end init_bindings






sub init_pads  ## initializes the pads at the specified level and also sets the wind
{

my ($level_val) = @_;


$R1 = $level{$level_val}{'pad'}[0]; 
$R2 = $level{$level_val}{'pad'}[1];
$R3 = $level{$level_val}{'pad'}[2];
$R4 = $level{$level_val}{'pad'}[3];

$B1 = $level{$level_val}{'pad'}[4];
$B2 = $level{$level_val}{'pad'}[5];
$B3 = $level{$level_val}{'pad'}[6];
$B4 = $level{$level_val}{'pad'}[7];

$G1 = $level{$level_val}{'pad'}[8];
$G2 = $level{$level_val}{'pad'}[9];
$G3 = $level{$level_val}{'pad'}[10];
$G4 = $level{$level_val}{'pad'}[11];




$pad{'red'} = $can->createRectangle( $R1, $R2, $R3,$R4, -fill  => 'red', -width => 1);
$pad{'blue'} = $can->createRectangle( $B1, $B2, $B3,$B4,-fill  => 'blue', -width => 1);
$pad{'green'} = $can->createRectangle( $G1, $G2, $G3,$G4,-fill  => 'green', -width => 1);

#print "\nRED PAD POSITION : $R1, $R2, $R3,$R4\n";
#print "\nBLUE PAD POSITION : $B1, $B2, $B3,$B4\n";
#print "\nGREEN PAD POSITION : $G1, $G2, $G3,$G4\n";


## wind 

#$wind = -50 + int(rand(100)); ## random wind
$wind = 0; ## no wind

$can->delete($wind_can{'arrow'});

#if($wind < 0) { $wind_can{'arrow'} = $can->createLine( $lower_X + 10, $upper_Y - 50 ,$lower_X + 80,$upper_Y - 50,-fill  => 'blue', -width => 4,-arrow =>'first',) ; }
#else
#{ $wind_can{'arrow'} = $can->createLine( $lower_X + 10, $upper_Y - 50 ,$lower_X + 80,$upper_Y - 50,-fill  => 'blue', -width => 4,-arrow =>'last',) ; } 



## obstacles

foreach my $i (keys % obstacle_coords_1)
{
$obstacles_1{$i} = $can->createRectangle( $obstacle_coords_1{$i}[0], $obstacle_coords_1{$i}[1], $obstacle_coords_1{$i}[2],$obstacle_coords_1{$i}[3], -fill  => 'black', -width => 1);
$obstacles_2{$i} = $can->createRectangle( $obstacle_coords_2{$i}[0], $obstacle_coords_2{$i}[1], $obstacle_coords_2{$i}[2],$obstacle_coords_2{$i}[3], -fill  => 'grey', -width => 1);

$obstacles_3{$i} = $can->createRectangle( $obstacle_coords_3{$i}[0], $obstacle_coords_3{$i}[1], $obstacle_coords_3{$i}[2],$obstacle_coords_3{$i}[3], -fill  => 'black', -width => 1);
$obstacles_4{$i} = $can->createRectangle( $obstacle_coords_4{$i}[0], $obstacle_coords_4{$i}[1], $obstacle_coords_4{$i}[2],$obstacle_coords_4{$i}[3], -fill  => 'black', -width => 1);

}


}



sub incline_canon
{

$can->delete($power{$cindex});
$can->delete($canon{$cindex});
$cindex++;


my $angle_rad = deg_to_rad($angle_deg);

my $new_X = $tank_length*cos($angle_rad);
my $new_Y = $tank_length*sin($angle_rad);


$canon{$cindex} = $can->createLine( $X,$Y, $X+$new_X,$Y+$new_Y,-fill  => 'red', -arrow =>'last',);
$power{$cindex} = $can->createLine($X,$Y, $X+$speed,$Y, -fill  => 'red', -arrow =>'last',);

if(exists $ball{$bindex})
{
$ball{$bindex}->set_coords($X,$Y);
}

$angle_deg = rad_to_deg($angle_rad);

#fit_to_canvas();
}





sub fit_to_canvas
{
#$can->CanvasFocus;
#$can->center($can->eventLocation);
$can->viewAll();
}


sub reset_canvas
{

$fire_count = 1;
$cindex = 1; 
$bindex = 1; 


foreach(keys %ball) { delete $ball{$_};}
foreach(keys %canon) { $can->delete($canon{$_}); }
foreach(keys %power) { $can->delete($power{$_}); }
foreach(keys %pad) { $can->delete($pad{$_}); }



#$can->delete($wind_can{'name'});
#$can->delete($wind_can{'arrow'}) ;
#$can->delete($wind_can{'val'});


foreach my $i (keys % obstacle_coords_1)
{
$can->delete($obstacles_1{$i});
$can->delete($obstacles_2{$i});
$can->delete($obstacles_3{$i});
$can->delete($obstacles_4{$i});
}

incline_canon();

$ball{$bindex} = Tk::GraphItems::Circle->new(canvas=>$can,colour=>'red','x'=> $X,'y'=> $Y, size => $ball_diameter);
$turn_color->configure(-background=>'red');

}





sub fire_canon
{

if($fire_count <= 6)
{
$time = 0;

$Button_fire->configure(-state=>disabled);

my $angle_rad = deg_to_rad($angle_deg);


my $pos_x = $X;
my $pos_y = $Y;

my $velocity_x = 0;
my $velocity_y = 0;

my $in_air = 1;

#print "\nThrowing with Velocity $speed and angle $angle_deg\n";
#print "\nTime $time :$pos_x,$pos_y";


while ($in_air == 1)
{
#$speed += $acceleration;

$time += 0.08;

$velocity_x = $speed*cos($angle_rad);
$velocity_y = $speed*sin($angle_rad);

$velocity_y -= $gravity; ## negative force due to gravity on Vy

$velocity_x += $wind; ## adding wind effect only to Vx
$velocity_y += $wind; ## adding wind effect only to Vy


$pos_x = $velocity_x*$time;
$pos_y = $Y + ($velocity_y*$time) - (0.5*$gravity*$time*$time);

## Hit obstacles

my $effect = has_hit_obstacle($pos_x, $pos_y);

if( $effect == 1 || $effect == 2 || $effect == 3) ## 1 = black ; 2 = grey ; 3 = horizontal hit
{
#print "\nHas hit obstacle $effect in flight";
bounce($speed,$angle_rad,$in_air,$time,$bindex,$pos_x,$pos_y,$effect);
last;  

}

## Reached floor

if($pos_y <= 0) 
{ 
$ball{$bindex}->set_coords($pos_x,0);

#fit_to_canvas();
$mw->update;

$in_air = 0; 
#print "\nReached ground $pos_x, $pos_y \n"; last;
}



## Reached walls & ceiling

if( ($pos_x >= $upper_X)  || ($pos_y >= $upper_Y) || ($pos_x <= $upper_XR)  || ($pos_y <= $upper_YR) ) 
{

if($pos_x > $upper_X) 
{ 
#$ball{$bindex}->set_coords($w,$pos_y); 
#print "\nLeft wall";
bounce($speed,$angle_rad,$in_air,$time,$bindex,$pos_x,$pos_y,3);
last;
} 

if($pos_y > $upper_Y) 
{ 
bounce($speed,$angle_rad,$in_air,$time,$bindex,$pos_x,$pos_y,2);
#$ball{$bindex}->set_coords($pos_x,$h); 
last;
}


if($pos_x <= $upper_XR) 
{ 
bounce($speed,$angle_rad,$in_air,$time,$bindex,$pos_x,$pos_y,3);
#$ball{$bindex}->set_coords(0,$pos_y); 
last;
} 

if($pos_y <= $upper_YR) 
{ $ball{$bindex}->set_coords($pos_x,0); } 



fit_to_canvas();
$mw->update;
	
$in_air = 0; 

#print "\nStuck in sky $pos_x, $pos_y\n"; last;
}

## else fly

else
{


if( has_hit_target($pos_x, $pos_y,$bindex) )	## Reached TARGET	
{

#print "\nGot it !! Score = $score\n";

$ball{$bindex}->set_coords($pos_x,$pos_y);

$mw->Dialog(-title => 'Info', 
   -text => "Got it !!",  -font => "verdana 10",
   -default_button => 'Ok', -buttons => [ 'Ok'], 
   -bitmap => 'info' )->Show( );

$in_air = 0;    

$score += 1;

last;  
}
else ##If not target then continue flight
{
$ball{$bindex}->set_coords($pos_x,$pos_y);

if($os eq 'win')
{
fit_to_canvas();
#$can->after(15);
}
else
{
$can->after(10);
}

$mw->update;
}



}

}


$bindex ++;

if($bindex == 2) { $ball{$bindex} = Tk::GraphItems::Circle->new(canvas=>$can,colour=>'red','x'=> $X,'y'=> $Y, size => $ball_diameter); $turn_color->configure(-background=>'red'); }
if($bindex == 3) { $ball{$bindex} = Tk::GraphItems::Circle->new(canvas=>$can,colour=>'blue','x'=> $X,'y'=> $Y, size => $ball_diameter); $turn_color->configure(-background=>'blue'); }
if($bindex == 4) { $ball{$bindex} = Tk::GraphItems::Circle->new(canvas=>$can,colour=>'blue','x'=> $X,'y'=> $Y, size => $ball_diameter); $turn_color->configure(-background=>'blue'); }
if($bindex == 5) { $ball{$bindex} = Tk::GraphItems::Circle->new(canvas=>$can,colour=>'green','x'=> $X,'y'=> $Y, size => $ball_diameter); $turn_color->configure(-background=>'green'); }
if($bindex == 6) { $ball{$bindex} = Tk::GraphItems::Circle->new(canvas=>$can,colour=>'green','x'=> $X,'y'=> $Y, size => $ball_diameter); $turn_color->configure(-background=>'green'); }

$fire_count ++;

$Button_fire->configure(-state=>active);

if($fire_count > 6)
{

$entry_score += 3;

if($score >= $entry_score)
{
if($level == $total_levels) 
{
$mw->Dialog(-title => 'Info', 
   -text => "Congrats !!!    
Game completed with Score $score",  -font => "verdana 10",
   -default_button => 'Ok', -buttons => [ 'Ok'], 
   -bitmap => 'info' )->Show( );
   
reset_canvas();	     
$level = 1;
$score = 0;
$entry_score = 0;
init_pads($level); 
}
else
{
$level ++;

$mw->Dialog(-title => 'Info', 
   -text => "Entering Level $level 
Your current Score $score",  -font => "verdana 10",
   -default_button => 'Ok', -buttons => [ 'Ok'], 
   -bitmap => 'info' )->Show( );

reset_canvas();	   
init_pads($level);
}
   
}
else
{
if($level == $total_levels)
{
$mw->Dialog(-title => 'Info', 
   -text => "Congrats !!!    
Game completed with Score $score",  -font => "verdana 10",
   -default_button => 'Ok', -buttons => [ 'Ok'], 
   -bitmap => 'info' )->Show( );
   
reset_canvas();	     
$level = 1;
$score = 0;
$entry_score = 0;
init_pads($level); 
}
else
{
$mw->Dialog(-title => 'Info', 
   -text => "Game Over :(    
Next level entry score:$entry_score Your score:$score",  -font => "verdana 10",
   -default_button => 'Ok', -buttons => [ 'Ok'], 
   -bitmap => 'info' )->Show( );
   
reset_canvas();	 
$level = 1;
$score = 0;
$entry_score = 0;
init_pads($level);  
}

}     



}


}


}




sub bounce
{
my ($b_speed,$b_angle,$in_air,$time,$bindex,$pos_x,$pos_y,$effect) = @_;

#print "\nStarting to bounce...$pos_x,$pos_y,$wind";

my $speed = 0;
my $angle_rad = 0;

$speed = 0.8*$speed;

if($effect == 1) ## black
{
$speed = $b_speed;
$angle_rad = $b_angle;
#$angle_rad = pi - $b_angle;
}
if($effect == 2) ## grey / Top wall
{
$speed = $b_speed;
$angle_rad = $b_angle*-1;
#$angle_rad = pi - $b_angle;
}
if($effect == 3) ## L wall
{
$speed = $b_speed;

if ($angle_rad > 1.57) 
{ 
#$angle_rad = $b_angle*-2;
$angle_rad = pi - $b_angle;
}
else 
{ 
#$angle_rad = $b_angle*2; 
$angle_rad = pi - $b_angle;
}

}

my $velocity_x = 0;
my $velocity_y = 0;

my $hit_x = $pos_x;
my $hit_y = $pos_y;

my $time = 0;



while ($in_air == 1)
{
$time += 0.08;

$velocity_x = $speed*cos($angle_rad);
$velocity_y = $speed*sin($angle_rad);

$velocity_y -= $gravity; ## negative force due to gravity on Vy
$velocity_x += $wind; ## adding wind effect only to Vx
$velocity_y += $wind; ## adding wind effect only to Vy

$pos_x = $hit_x + $velocity_x*$time;
$pos_y = $hit_y + ($velocity_y*$time) - (0.5*$gravity*$time*$time);



## Hit obstacles

$effect = has_hit_obstacle($pos_x, $pos_y);

if( $effect == 1 || $effect == 2 || $effect == 3) ## 1 = black ; 2 = grey; 3 = horizontal hit
{
#print "\nHas hit obstacle $effect in bounce";
bounce($speed,$angle_rad,$in_air,$time,$bindex,$pos_x,$pos_y,$effect);
$in_air = 0; 
last;  
}


## Reached floor

if($pos_y <= 0) 
{ 
$ball{$bindex}->set_coords($pos_x,0);

#fit_to_canvas();
$mw->update;

$in_air = 0; 
#print "\nBounce reached ground $pos_x, $pos_y\n"; last;
}

## Reached walls & ceiling

if( ($pos_x >= $upper_X)  || ($pos_y >= $upper_Y) || ($pos_x <= $upper_XR)  || ($pos_y <= $upper_YR) ) 
{

if($pos_x >= $upper_X) 
{ 
#$ball{$bindex}->set_coords($w,$pos_y); 
bounce($speed,$angle_rad,$in_air,$time,$bindex,$pos_x,$pos_y,3);
last;
} 

if($pos_y >= $upper_Y) 
{ 
bounce($speed,$angle_rad,$in_air,$time,$bindex,$pos_x,$pos_y,2);
#$ball{$bindex}->set_coords($pos_x,$h); 
last;
} 

if($pos_x <= $upper_XR) 
{ 
bounce($speed,$angle_rad,$in_air,$time,$bindex,$pos_x,$pos_y,3);
#$ball{$bindex}->set_coords(0,$pos_y); 
last;
} 

if($pos_y <= $upper_YR) 
{ $ball{$bindex}->set_coords($pos_x,0); } 



#fit_to_canvas();
$mw->update;
	
$in_air = 0; 

#print "\nBounce stuck in sky $pos_x, $pos_y\n"; last;
}

else
{

if( has_hit_target($pos_x, $pos_y,$bindex) )	## Reached TARGET	
{

print "\nGot it !! Score = $score\n";

$ball{$bindex}->set_coords($pos_x,$pos_y);

$mw->Dialog(-title => 'Info', 
   -text => "Got it !!",  -font => "verdana 10",
   -default_button => 'Ok', -buttons => [ 'Ok'], 
   -bitmap => 'info' )->Show( );

$in_air = 0;    

$score += 1;

last;  
}
else
{
$ball{$bindex}->set_coords($pos_x,$pos_y);

if($os eq 'win')
{
fit_to_canvas();
#$can->after(15);
}
else
{
$can->after(10);
}

$mw->update;

#print "\nBouncing $pos_x, $pos_y\n";
}
}

} ## end while


}






sub has_hit_obstacle
{
my ($pos_x, $pos_y) = @_;
my $flag = 0;


foreach my $i(keys %obstacle_coords_1)
{
my ($Ax1,$Ay1,$Ax2,$Ay2) = ($obstacle_coords_1{$i}[0], $obstacle_coords_1{$i}[1], $obstacle_coords_1{$i}[2],$obstacle_coords_1{$i}[3]);
my ($Bx1,$By1,$Bx2,$By2) = ($obstacle_coords_2{$i}[0], $obstacle_coords_2{$i}[1], $obstacle_coords_2{$i}[2],$obstacle_coords_2{$i}[3]);



=pod
####
------------------------------------------------------------------------|
(w,h)																	|
																		|
																		|
      (Ax1,Ay1) |-----------------------| (Ax2,Ay1)						|
				|		(A)				|								|
      (Bx1,By1)	|-----------------------| (Ax2,Ay2)						|
				|		(B)				|								|
      (Bx1,By1)	|-----------------------| (Bx2,By2)         			|
																		|
																		|
																(0,0)	|
------------------------------------------------------------------------|
###
=cut



my $dist1 = distance($pos_x,$pos_y,$Bx1,$By1);
my $dist2 = distance($pos_x,$pos_y,$Ax2,$Ay2);

if( $dist1 <= $ball_radius || $dist2 <= $ball_radius ) ## strikes from any horizontal side
{
$flag = 3; last;
}

if( $pos_y <= $By1 && $pos_y >= $By2 ) 	  ## strikes from below on grey
{


	if ($pos_x <= $Bx1 && $pos_x >= $Bx2 ) 
	{ $flag = 2; last; }



}

if( $pos_y <= $Ay1 && $pos_y >= $Ay2 )		   ## strikes from above on black
{


	if( $pos_x <= $Ax1 && $pos_x >= $Ax2 ) 
	{ $flag = 1; last; }
}






}

return $flag;
}






sub has_hit_target
{
my ($pos_x, $pos_y, $bindex) = @_;
my $flag = 0;


if(($bindex == 1) || ($bindex == 2) ) ##red
{
$flag = check_collision($R1,$R2,$R3,$R4,$pos_x,$pos_y,$ball_radius);
}

if(($bindex == 3) || ($bindex == 4) ) ##blue
{
$flag = check_collision($B1,$B2,$B3,$B4,$pos_x,$pos_y,$ball_radius);
}

if(($bindex == 5) || ($bindex == 6) ) ##green
{
$flag = check_collision($G1,$G2,$G3,$G4,$pos_x,$pos_y,$ball_radius);
}


return $flag;
}






###################################################################
sub deg_to_rad { ($_[0]/180) * pi }
sub rad_to_deg { ($_[0]/pi) * 180 }
sub asin { atan2($_[0], sqrt(1 - $_[0] * $_[0])) }
sub acos { atan2( sqrt(abs((1 - $_[0] * $_[0]))), $_[0] ) }
sub tan  { sin($_[0]) / cos($_[0])  }
sub atan { atan2($_[0],1) };
###################################################################


sub distance
{
my ($x1,$y1,$x2,$y2) = @_;

my $pt_distance = 0;
$pt_distance = sqrt( (($x2-$x1)*($x2-$x1)) + (($y2-$y1)*($y2-$y1)) );

return $pt_distance;
}


sub check_collision
{
my ($x1,$y1,$x2,$y2,$pos_x, $pos_y,$ball_radius) = @_;


=pod
####

        (x2,y2) |-----------2-----------| (x1,y2)				
				|						|
				4                       3 		
				|						|				
		(x2,y1) |-----------1-----------| (x1,y1)         	

															(0,0)
###
=cut


my ($x,$y) = (0,0);
my $collide = 0;


for($x=$x1;$x<=$x2;$x++) ## 1
{
$y = $y1;
my $dist = distance($pos_x,$pos_y,$x,$y);
if($dist <= $ball_radius) { $collide = 1; last;}
}


for($x=$x1;$x<=$x2;$x++) ## 2
{
$y = $y2;
my $dist = distance($pos_x,$pos_y,$x,$y);
if($dist <= $ball_radius) { $collide = 1; last;}
}

for($y=$y1;$y<=$y2;$y++) ## 3
{
$x = $x1;
my $dist = distance($pos_x,$pos_y,$x,$y);
if($dist <= $ball_radius) { $collide = 1; last;}
}


for($y=$y1;$y<=$y2;$y++) ## 4
{
$x = $x2;
my $dist = distance($pos_x,$pos_y,$x,$y);
if($dist <= $ball_radius) { $collide = 1; last;}
}




return $collide;
}



