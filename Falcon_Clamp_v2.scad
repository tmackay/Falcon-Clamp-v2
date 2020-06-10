// OpenSCAD Compound Planetary System
// (c) 2019, tmackay
//
// Licensed under a Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0) license, http://creativecommons.org/licenses/by-sa/4.0.

// Which one would you like to see?
part = "2D"; // [2D:Gear Test,3D:Overhang Test,core:Core]

// Use for command line option '-Dgen=n', overrides 'part'
// 0-7+ - generate parts individually in assembled positions. Combine with MeshLab.
// 0 box
// 1 ring gears and jaws
// 2 sun gear and knob
// 3+ planet gears
g=undef;

// Overall scale (to avoid small numbers, internal faces or non-manifold edges) - seems to give better results than overlap (not yet implemented)
scl = 1;
// Height of planetary layers
gh = [7.4, 7.6, 7.6];
// Modules, planetary layers
modules = len(gh);
// Number of planet gears in inner circle
planets = 5; //[3:1:21]
// Number of teeth in inner planet gears
pt=[5,4,5];

// Sun gear multiplier
sgm = 1; //[1:1:5]
// For fused sun gears, we require them to be a multiple of the planet teeth
dt = pt*sgm;
// For additional gear ratios we can add or subtract extra teeth (in multiples of planets) from rings but the profile will be further from ideal
of = [0,0,0];
// Profile Shift
ps = [-0.1,-0.1,-0.1];
// Number of teeth in ring gears
rt = [for(i=[0:modules-1])round((2*dt[i]+2*pt[i])/planets+of[i])*planets-dt[i]];
// Shaft diameter
shaft_d = 0; //[0:0.1:25]
// secondary shafts (for larger sun gears)
shafts = 6; //[0:1:12]
// Outer diameter
outer_d = 25; //[30:300]
// Outer teeth
outer_t = 0; //[0:1:24]
// Width of outer teeth
outer_w=3; //[0:0.1:10]
// Ring wall thickness (relative pitch radius)
wall = 3.5; //[0:0.1:20]
// number of teeth to twist across
nTwist=1; //[0:0.5:5]
nt = [1,1,1];
// Gear depth ratio - actually just trims addendum radius - this could be automatic based on gear interference
dr = [0.5,0.4,0.5];
// Gear clearance
tol=0.1; //[0:0.01:0.5]
// pressure angle
P=40; //[30:60]
// increase for enhanced resolution beware: large numbers will take lots of time!
iterations = 24; //[10:10:200]
slices = iterations;
// Layer height (for ring horizontal split)
layer_h = 0.2; //[0:0.01:1]
// Bearing height
bearing_h = 1;  //[0:0.01:5]
// Chamfer exposed gears, top - watch fingers
ChamferGearsTop = 0;				// [1:No, 0.5:Yes, 0:Half]
// Chamfer exposed gears, bottom - help with elephant's foot/tolerance
ChamferGearsBottom = 0;				// [1:No, 0.5:Yes, 0:Half]
// Number of sets of jaws
jaws = 1; //[0:1:6]
// Jaw Initial Rotation (from closed)
jaw_rot = 180; //[0:180]
// Jaw Size
jaw_size = 22; //[0:100]
// Jaw Offset
jaw_offset = 3; //[0:0.1:100]
// Jaw Taper Angle (outside edge)
jaw_angle = 9; //[0:60]
// Dimple radius
dim_r = 1.1; //[0:0.1:2]
// Dimple depth ratio
dim_d = 0.5; //[0:0.1:1]
dim_n = floor(addl(gh,modules)/dim_r/3);
dim_s = addl(gh,modules)/(dim_n+1);
//Include a knob
Knob = 1;				// [1:Yes , 0:No]
//Diameter of the knob, in mm
KnobDiameter		= 12.0;			//[10:0.5:100]
//Thickness of knob, including the stem, in mm:
KnobTotalHeight 	= 10;			//[10:thin,15:normal,30:thick, 40:very thick]
//Number of points on the knob
FingerPoints		= 5;   			//[3,4,5,6,7,8,9,10]
//Diameter of finger holes
FingerHoleDiameter	= 5; //[5:0.5:50]
TaperFingerPoints	= true;			// true

//
// Include Nut Captures at base of stem and/or on top of part
// If using a hex-head bolt for knob, include Top Nut Capture only.
// including both top and bottom captures allows creation of a knob 
// with nuts top and bottom for strength/stability when using all-thread rod
//

//Include a nut capture at the top
TopNutCapture = 0;				//[1:Yes , 0:No]
//Include a nut capture at the base
BaseNutCapture = 0/1;				// [1:Yes , 0:No]

// Curve resolution settings, minimum angle
$fa = 5/1;
// Curve resolution settings, minimum size
$fs = 1/1;

// Calculate cp based on desired ring wall thickness
//cp=(outer_d/2-wall)*360/(drive_t+2*planet_t);
cp=(outer_d/2-wall)*360/(dt+2*pt);
// what ring should be for teeth to mesh without additional scaling
rtn = dt+2*pt;
// scale ring gear (approximate profile shift)
s=[for(i=[0:modules-1])rtn[i]/rt[i]];
// scale helix angle to mesh
ha=[for(i=[0:modules-1])atan(PI*nt[i]*cp[i]/90/gh[i])];
has=[for(i=[0:modules-1])atan(PI*nt[i]*s[i]*cp[i]/90/gh[i])];

// Planetary gear ratio for fixed ring: 1:1+R/S
// (Planet/Ring interaction: Nr*wr-Np*wp=(Nr-Np)*wc)
// one revolution of carrier (wc=1) turns planets on their axis
// wp = (Np-Nr)/Np = eg. (10-31)/10=-2.1 turns
// Secondary Planet/Ring interaction
// wr = ((Nr-Np)+Np*wp)/Nr = eg. ((34-11)-11*2.1)/34 = 1/340
// or Nr2/((Nr2-Np2)+Np2*(Np1-Nr1)/Np1)

// sanity check
for (i=[1:modules-1]){
    if ((dt[i]+rt[i])%planets)
        echo(str("Warning: For even spacing, planets (", i, ") must divide ", dt[i]+rt[i]));
    if (dt[i] + 2*pt[i] != rt[i])
        echo(str("Teeth fewer than ideal (ring", i, "): ", dt[i]+2*pt[i]-rt[i]));
    if(i<modules-1)echo(str("Input/Output gear ratio (ring", i, "): 1:",abs((1+rt[modules-1]/dt[modules-1])*rt[i]/((rt[i]-pt[i])+pt[i]*(pt[modules-1]-rt[modules-1])/pt[modules-1]))));
}

// Tolerances for geometry connections.
AT=1/64;
ST=AT*2;
TT=AT/2;

$fn=96;

// Knob
// by Hank Cowdog
// 2 Feb 2015
//
// based on FastRyan's
// Tension knob 
// Thingiverse Thing http://www.thingiverse.com/thing:27502/ 
// which was downloaded on 2 Feb 2015 
//
// GNU General Public License, version 2
// http://www.gnu.org/licenses/gpl-2.0.html
//
//This program is free software; you can redistribute it and/or
//modify it under the terms of the GNU General Public License
//as published by the Free Software Foundation; either version 2
//of the License, or (at your option) any later version.
//
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//
//
// 
//
//
//
// Finger points are the points on a star knob.
// Finger holes are the notches between each point.
// Larger values make for deeper holes.
// Too many/too deep and you may reduce knob size too much.
// If $TaperFingerPoints is true, the edges will be eased a little, making 
// for a nicer knob to hold/use. 
//

//Ratio of stem to total height smaller makes for less of a stem under the knob:
//StemHeightPercent =30.0/100.0;			// [0.3:0.8]

// The shaft is for a thru-hole.  Easing the shaft by a small percentage makes for
// easier insertion and makes allowance for ooze on 3D filament printers 

//Diameter of the shaft thru-bolt, in mm 
ShaftDiameter = shaft_d;

ShaftEasingPercentage = 0/100.0;  // 10% is plenty

NutFlatWidth = 1.75 * ShaftDiameter;
NutHeight =     0.87 * ShaftDiameter;
SineOfSixtyDegrees = 0.86602540378/1.0;

NutPointWidth = NutFlatWidth /SineOfSixtyDegrees;

//StemDiameter= KnobDiameter/2.0;
//StemHeight = KnobTotalHeight  * StemHeightPercent;

EasedShaftDiameter = ShaftDiameter * (1.0+ShaftEasingPercentage);

// center gears
if(g==2||g==undef&&part=="core")difference(){
    union(){
        if(Knob)translate([0,0,addl(gh,modules)]){
            intersection(){
                translate([0,0,KnobTotalHeight])mirror([0,0,1])difference() {
                    // The whole knob
                    cylinder(h=KnobTotalHeight+TT, r=KnobDiameter/2);
                    // each finger point
                    for (i = [0 : FingerPoints-1]){
                        rotate( i * 360 / FingerPoints, [0, 0, 1])
                        translate([0, (KnobDiameter *.6), -1])
                        union() {
                            // remove the vertical part of the finger hole 
                            cylinder(h=KnobTotalHeight+2, r=FingerHoleDiameter/2);
                            // taper the sides of the finger points 
                            if(TaperFingerPoints) {
                                rotate_extrude(convexity = 10)
                                    translate([FingerHoleDiameter/2.0, 0, 0])
                                    polygon( points=scl*[[2,-3],[-1,6],[-1,-3]] );
                            }
                        }
                    }
                    // Drill the shaft and nut captures
                    translate([0,0,KnobTotalHeight+1])scale([1,1,-1])union(){
                    //The thru-shaft
                        cylinder(h=KnobTotalHeight+2, r=EasedShaftDiameter/2.);
                        // Drill the nut capture
                        if (1 == BaseNutCapture) {
                            cylinder(h=NutHeight + 1, r=NutPointWidth/2.0, $fn=6);
                        }
                    }
                    // Drill the 2nd nut capture      
                    if (1==TopNutCapture){ 
                        translate([0,0,-1])
                            cylinder(h=NutHeight + 1, r=NutPointWidth/2.0, $fn=6);
                    }
                    // taper the ends of the points
                    if(TaperFingerPoints) {
                        rotate_extrude(convexity = 10)
                        translate([KnobDiameter/2, 0, 0])
                        polygon( points=scl*[[-2,-3],[1,6],[1,-3]] );
                    }
                }	
                // Transition knob to gear. Cutout overhanging teeth at angle
                rotate([0,0,180/dt[modules-1]*(1+2*nt[modules-1]-pt[modules-1]%2)])
                    sun2DS(pt[modules-1],dt[modules-1],PI*cp[modules-1]/180,P,dr[modules-1],-ps[modules-1],tol,KnobTotalHeight);
            }
        }
        // center gears
        for (i = [0:modules-1]){
            // the gear itself
            translate([0,0,addl(gh,i)])intersection(){
                rotate([0,0,180/dt[i]*(1-pt[i]%2)])
                    extrudegear(t1=dt[i],reverse=true,bore=0,cp=cp[i],helix_angle=ha[i],gear_h=gh[i],rot=180/dt[i]*(1-pt[i]%2))
                        sun2D(pt[i],dt[i],PI*cp[i]/180,P,dr[i],-ps[i],tol);
                // chamfer bottom gear
                if(ChamferGearsBottom<1&&i==0)rotate(90/pt[i])translate([0,0,-TT])
                    linear_extrude(height=gh[i]+AT,scale=1+gh[i]/(dt[i]*cp[i]/360)*sqrt(3),slices=1)
                        circle($fn=dt[i]*2,r=dt[i]*cp[i]/360-ChamferGearsBottom*min(cp[i]/(2*tan(P))+tol,dr[i]*cp[i]*PI/180+tol));
                // cutout overhanging teeth at angle
                if(i>0)rotate([0,0,180/dt[i-1]*(1+2*nt[i-1]-pt[i-1]%2)])
                    sun2DS(pt[i-1],dt[i-1],PI*cp[i-1]/180,P,dr[i-1],-ps[i-1],tol,gh[i]);
                // chamfer top gear
                if(!Knob&&ChamferGearsTop<1&&i==modules-1)translate([0,0,gh[i]+TT])rotate(90/dt[i])mirror([0,0,1])
                    linear_extrude(height=gh[i]+ST,scale=1+gh[i]/(dt[i]*cp[i]/360)*sqrt(3),slices=1)
                        circle($fn=dt[i]*2,r=dt[i]*cp[i]/360-ChamferGearsTop*min(cp[i]/(2*tan(P))+tol,dr[i]*cp[i]*PI/180+tol));
            }
        }
    }
    // cylinder shaft_d
    translate([0,0,-AT])cylinder(d=shaft_d,h=addl(gh,modules)+ST,$fn=6);
}

// planets
if(g>2||g==undef&&part=="core"){
    planets(t1=pt[0],t2=dt[0],offset=(dt[0]+pt[0])*cp[0]/360,n=planets,t=rt[0]+dt[0])difference(){
        for (i=[0:modules-1]){
            translate([0,0,addl(gh,i)]){
                intersection(){
                    // the gear itself
                    extrudegear(t1=pt[i],bore=0,cp=cp[i],helix_angle=ha[i],gear_h=gh[i])
                        gear2D(pt[i],cp[i]*PI/180,P,dr[i],ps[i],tol);
                    // chamfer bottom gear
                    if(ChamferGearsBottom<1&&i==0)rotate(90/pt[i])translate([0,0,-TT])
                        linear_extrude(height=gh[i]+AT,scale=1+gh[i]/(pt[i]*cp[i]/360)*sqrt(3),slices=1)
                            circle($fn=pt[i]*2,r=pt[i]*cp[i]/360-ChamferGearsBottom*min(cp[i]/(2*tan(P))+tol,dr[i]*cp[i]*PI/180+tol));                
                    // cutout overhanging teeth at angle
                    if(i>0)rotate([0,0,180/pt[i-1]*(-2*nt[i-1])])
                        gear2DS(pt[i-1],cp[i-1]*PI/180,P,dr[i],ps[i-1],tol,gh[i]);
                    // chamfer top gear
                    if(ChamferGearsTop<1&&i==modules-1)translate([0,0,gh[i]+TT])rotate(90/pt[i])mirror([0,0,1])
                        linear_extrude(height=gh[i]+ST,scale=1+gh[i]/(pt[i]*cp[i]/360)*sqrt(3),slices=1)
                            circle($fn=pt[i]*2,r=pt[i]*cp[i]/360-ChamferGearsTop*min(cp[i]/(2*tan(P))+tol,dr[i]*cp[i]*PI/180+tol));
                }
            }
        }
        if(pt[0]*cp[0]/360-ChamferGearsTop*min(cp[0]/(2*tan(P))+tol) > shaft_d)
            translate([0,0,-TT])cylinder(d=shaft_d,h=addl(gh,modules)+AT);
    }
}

// Ring gears
if(g==1||g==undef&&part=="core"){
    difference(){
        // positive volume
        for (i=[0:modules-1])translate([0,0,addl(gh,i)]){
            // ring body
            intersection(){
                extrudegear(t1=rt[i],gear_h=gh[i],tol=-tol,helix_angle=has[i],cp=cp[i],AT=ST)
                    ring2D(outer_d/2,dt[i],pt[i],rt[i],PI*cp[i]/180,P,dr[i],-ps[i],-tol);
                // cutout overhanging teeth at angle
                if(i>0)rotate([0,0,-180/rt[i-1]*2*nt[i-1]*s[i-1]])
                    ring2DS(outer_d/2,dt[i-1],pt[i-1],rt[i-1],PI*cp[i-1]/180,P,dr[i-1],-ps[i-1],-tol,gh[i]);
            }
            // Jaws - TODO: generalise for modules (alternating hinge pattern)
            // only once (for now) but included in loop for implicit union efficiency
            if(i==0)for(k=[0:jaws-1])rotate([0,0,k*360/jaws]){
                for(i=[dim_s/2:dim_s:jaw_size-dim_s/2+AT],j=[dim_s/2:dim_s:addl(gh,modules)-dim_s/2+AT])
                    translate([outer_d/2+jaw_size-i,jaw_offset,j])
                        scale([1,dim_d,1])rotate([90,0,0])sphere(r=dim_r,$fn=6);
                difference(){
                    intersection(){
                        translate([0,jaw_offset,0])
                            cube([outer_d/2+jaw_size,outer_d/2-jaw_offset,addl(gh,modules)]);
                        rotate([0,0,-jaw_angle])
                            cube([outer_d/2+jaw_size,outer_d/2,addl(gh,modules)]);
                    }
                    translate([0,0,-AT])
                        cylinder(r=outer_d/2-2*tol,h=gh[0]+ST);
                    translate([0,0,gh[0]-layer_h*4-AT])
                        cylinder(r=outer_d/2+2*tol,h=gh[1]+layer_h-TT+4*layer_h-AT-TT+layer_h*4+AT+AT+TT);
                    translate([0,0,gh[0]+gh[1]+layer_h-AT])
                        cylinder(r=outer_d/2-2*tol,h=gh[0]+ST);
                    for(i=[dim_s:dim_s:jaw_size-dim_s+AT],j=[dim_s:dim_s:addl(gh,modules)-dim_s+AT])
                        translate([outer_d/2+jaw_size-i,jaw_offset,j])
                            scale([1,dim_d,1])rotate([90,0,0])sphere(r=dim_r,$fn=6);
                }
                rotate([0,0,-jaw_rot])mirror([0,1,0]){
                    for(i=[dim_s:dim_s:jaw_size-dim_s+AT+0.01],j=[dim_s:dim_s:addl(gh,modules)-dim_s+AT])
                        translate([outer_d/2+jaw_size-i,jaw_offset,j])
                            scale([1,dim_d,1])rotate([90,0,0])sphere(r=dim_r,$fn=6);
                    difference(){
                        intersection(){
                            translate([0,jaw_offset,0])
                                cube([outer_d/2+jaw_size,outer_d/2-jaw_offset,addl(gh,modules)]);
                            rotate([0,0,-jaw_angle])
                                cube([outer_d/2+jaw_size,outer_d/2,addl(gh,modules)]);
                        }
                        translate([0,0,-AT])
                            cylinder(r=outer_d/2+2*tol,h=gh[0]+layer_h+AT-layer_h*4-TT);
                        translate([0,0,gh[0]-layer_h*4])
                            cylinder(r=outer_d/2-2*tol,h=gh[1]+layer_h-TT+layer_h*9);
                        translate([0,0,gh[0]+gh[1]-TT+layer_h*4-TT])
                            cylinder(r=outer_d/2+2*tol,h=gh[2]+ST-layer_h*4+TT);
                        for(i=[dim_s/2:dim_s:jaw_size-dim_s/2+AT],j=[dim_s/2:dim_s:addl(gh,modules)-dim_s/2+AT])
                            translate([outer_d/2+jaw_size-i,jaw_offset,j])
                                scale([1,dim_d,1])rotate([90,0,0])sphere(r=dim_r,$fn=6);
                    }
                }
            }
        }
        // negative volume
        for (i=[0:modules-1])translate([0,0,addl(gh,i)]){
            // bearing surface
            if(i>0&&(pt[i-1]-rt[i-1])/pt[i-1]!=(pt[i]-rt[i])/pt[i])
                rotate_extrude()translate([0,(i%2?0:layer_h)-TT,0])mirror([0,i%2?1:0,0])
                    polygon(points=[[outer_d/2+tol,bearing_h-layer_h],[outer_d/2-wall/2-tol,bearing_h-layer_h],
                        [outer_d/2-wall/2-tol,0],[0,0],[0,-layer_h],[outer_d/2-wall/2+tol,-layer_h],
                        [outer_d/2-wall/2+tol,bearing_h-2*layer_h],[outer_d/2+tol,bearing_h-2*layer_h]]);
            // chamfer bottom gear
            if(ChamferGearsBottom<1&&i==0)translate([0,0,-TT])
                linear_extrude(height=(rt[i]*s[i]*cp[i]/360)/sqrt(3),scale=0,slices=1)
                    if(ChamferGearsTop>0)
                        hull()gear2D(rt[i],s[i]*cp[i]*PI/180,P,dr[i],-tol);
                    else
                        circle($fn=rt[i]*2,r=rt[i]*s[i]*cp[i]/360);
            // chamfer top gear
            if(ChamferGearsTop<1&&i==modules-1)translate([0,0,gh[i]+TT])mirror([0,0,1])
                linear_extrude(height=(rt[i]*s[i]*cp[i]/360)/sqrt(3),scale=0,slices=1)
                    if(ChamferGearsTop>0)
                        hull()gear2D(rt[i],s[i]*cp[i]*PI/180,P,dr[i],-tol);
                    else
                        circle($fn=rt[i]*2,r=rt[i]*s[i]*cp[i]/360);
        }
    }
}

if(g==undef&&part=="2D"){
    for(i=[0:1])translate([0,i*(outer_d+tol),0]){
        planets(t1=pt[i], t2=dt[i],offset=(dt[i]+pt[i])*cp[i]/360,n=planets,t=rt[i]+dt[i])
            gear2D(pt[i],PI*cp[i]/180,P,dr[i],ps[i],tol);
        ring2D(outer_d/2,dt[i],pt[i],rt[i],PI*cp[i]/180,P,dr[i],-ps[i],-tol);
        rotate([0,0,180/dt[i]*(1-pt[i]%2)])
            sun2D(pt[i],dt[i],PI*cp[i]/180,P,dr[i],-ps[i],tol);
    }
    //translate([outer_d+tol,0,0])Rack(m = 2, z = 10, x = 0, y = 1, w = 20, clearance = tol);
    //translate(-[outer_d+tol,0,0])gear2D(1,PI*cp[0]/180,P,1,0.4,tol);
    
    // Jaws - TODO: generalise for modules (alternating hinge pattern)
    for(k=[0:jaws-1])rotate([0,0,k*360/jaws]){
        difference(){
            intersection(){
                translate([0,jaw_offset,0])
                    square([outer_d/2+jaw_size,outer_d/2-jaw_offset]);
                rotate([0,0,-jaw_angle])
                    square([outer_d/2+jaw_size,outer_d/2]);
            }
            circle(r=outer_d/2+2*tol);
        }
        rotate([0,0,-jaw_rot])mirror([0,1,0]){
            difference(){
                intersection(){
                    translate([0,jaw_offset,0])
                        square([outer_d/2+jaw_size,outer_d/2-jaw_offset]);
                    rotate([0,0,-jaw_angle])
                        square([outer_d/2+jaw_size,outer_d/2]);
                }
                circle(r=outer_d/2+2*tol);
            }
        }
    }
}

// test overhang removal
if(g==undef&&part=="3D"){
    //gear2DS(pt[0],cp[0]*PI/180,P,dr[1],ps[0],tol,gh[1]);
    //sun2DS(pt[0],dt[0],PI*cp[0]/180,P,dr[0],-ps[0],tol,gh[1]);
    ring2DS(outer_d/2,dt[0],pt[0],rt[0],PI*cp[0]/180,P,dr[0],-ps[0],-tol,gh[1]);
}

// reversible herringbone gear with bore hole
module extrudegear(t1=13,reverse=false,bore=0,rot=0,helix_angle=0,gear_h=10,cp=10){
    difference() {
        translate([0,0,gear_h/2])
        if (reverse) {
            mirror([0,1,0])
                herringbone(t1,PI*cp/180,P,tol,helix_angle,gear_h,AT=AT)
                    children();
        } else {
            herringbone(t1,PI*cp/180,P,tol,helix_angle,gear_h,AT=AT)
                children();
        }
    }
}

// reversible herringbone gear with bore hole
module planetgear(t1=13,reverse=false,bore=0,rot=0)
{
    difference()
    {
        translate([0,0,gear_h/2])
        if (reverse) {
            mirror([0,1,0])
                herringbone(t1,PI*cp/180,P,depth_ratio,tol,helix_angle,gear_h,AT=AT);
        } else {
            herringbone(t1,PI*cp/180,P,depth_ratio,tol,helix_angle,gear_h,AT=AT);
        }
        
        translate([0,0,-TT]){
            rotate([0,0,-rot])
                cylinder(d=bore, h=2*gear_h+AT);
            // Extra speed holes, for strength
            if(shafts>0 && bore>0 && bore/4+(t1-2*tan(P))*cp/720>bore)
                for(i = [0:360/shafts:360-360/shafts])rotate([0,0,i-rot])
                    translate([bore/4+(t1-2*tan(P))*cp/720,0,-AT])
                        cylinder(d=bore,h=2*gear_h+AT);
        }
    }
}

// Space out planet gears approximately equally
module planets(t1,t2,offset,n,t)
{
    for(i = [0:n-1])if(g==undef||i==g-3)
    rotate([0,0,round(i*t/n)*360/t])
        translate([offset,0,0]) rotate([0,0,round(i*t/n)*360/t*t2/t1])
            children();
}

// Herringbone gear code, taken from:
// Planetary gear bearing (customizable)
// https://www.thingiverse.com/thing:138222
// Captive Planetary Gear Set: parametric. by terrym is licensed under the Creative Commons - Attribution - Share Alike license.
module herringbone(
	number_of_teeth=15,
	circular_pitch=10,
	pressure_angle=28,
	clearance=0,
	helix_angle=0,
	gear_thickness=5){
union(){
    gear(number_of_teeth,
		circular_pitch,
		pressure_angle,
		clearance,
		helix_angle,
		gear_thickness/2)
            children();
	mirror([0,0,1])
		gear(number_of_teeth,
			circular_pitch,
			pressure_angle,
			clearance,
			helix_angle,
			gear_thickness/2)
            children();
}}

module gear (
	number_of_teeth=15,
	circular_pitch=10,
	pressure_angle=28,
	clearance=0,
	helix_angle=0,
	gear_thickness=5,
	flat=false){
pitch_radius = number_of_teeth*circular_pitch/(2*PI);
twist=tan(helix_angle)*gear_thickness/pitch_radius*180/PI;

flat_extrude(h=gear_thickness,twist=twist,flat=flat)
        children();
}

module flat_extrude(h,twist,flat){
	if(flat==false)
		linear_extrude(height=h,twist=twist,slices=slices)children(0);
	else
		children(0);
}

module gear2D__ (
	number_of_teeth,
	circular_pitch,
	pressure_angle,
	depth_ratio,
	clearance){
pitch_radius = number_of_teeth*circular_pitch/(2*PI);
base_radius = pitch_radius*cos(pressure_angle);
depth=circular_pitch/(2*tan(pressure_angle));
outer_radius = clearance<0 ? pitch_radius+depth/2-clearance : pitch_radius+depth/2;
root_radius1 = pitch_radius-depth/2-clearance/2;
root_radius = (clearance<0 && root_radius1<base_radius) ? base_radius : root_radius1;
backlash_angle = clearance/(pitch_radius*cos(pressure_angle)) * 180 / PI;
half_thick_angle = 90/number_of_teeth - backlash_angle/2;
pitch_point = involute (base_radius, involute_intersect_angle (base_radius, pitch_radius));
pitch_angle = atan2 (pitch_point[1], pitch_point[0]);
min_radius = max (base_radius,root_radius);

intersection(){
	rotate(90/number_of_teeth)
		circle($fn=number_of_teeth*3,r=pitch_radius+depth_ratio*circular_pitch/2-clearance/2);
	union(){
		rotate(90/number_of_teeth)
			circle($fn=number_of_teeth*2,r=max(root_radius,pitch_radius-depth_ratio*circular_pitch/2-clearance/2));
		for (i = [1:number_of_teeth])rotate(i*360/number_of_teeth){
			halftooth (
				pitch_angle,
				base_radius,
				min_radius,
				outer_radius,
				half_thick_angle);		
			mirror([0,1])halftooth (
				pitch_angle,
				base_radius,
				min_radius,
				outer_radius,
				half_thick_angle);
		}
	}
}}

module halftooth (
	pitch_angle,
	base_radius,
	min_radius,
	outer_radius,
	half_thick_angle){
index=[0,1,2,3,4,5];
start_angle = max(involute_intersect_angle (base_radius, min_radius)-5,0);
stop_angle = involute_intersect_angle (base_radius, outer_radius);
angle=index*(stop_angle-start_angle)/index[len(index)-1];
p=[[0,0], // The more of these the smoother the involute shape of the teeth.
	involute(base_radius,angle[0]+start_angle),
	involute(base_radius,angle[1]+start_angle),
	involute(base_radius,angle[2]+start_angle),
	involute(base_radius,angle[3]+start_angle),
	involute(base_radius,angle[4]+start_angle),
	involute(base_radius,angle[5]+start_angle)];

difference(){
	rotate(-pitch_angle-half_thick_angle)polygon(points=p);
	square(2*outer_radius);
}}

// Mathematical Functions
//===============

// Finds the angle of the involute about the base radius at the given distance (radius) from it's center.
//source: http://www.mathhelpforum.com/math-help/geometry/136011-circle-involute-solving-y-any-given-x.html

function involute_intersect_angle (base_radius, radius) = sqrt (pow (radius/base_radius, 2) - 1) * 180 / PI;

// Calculate the involute position for a given base radius and involute angle.

function involute (base_radius, involute_angle) =
[
	base_radius*(cos (involute_angle) + involute_angle*PI/180*sin (involute_angle)),
	base_radius*(sin (involute_angle) - involute_angle*PI/180*cos (involute_angle))
];

// Recursively sums all elements of a list up to n'th element, counting from 1
function addl(list,n=0) = n>0?(n<=len(list)?list[n-1]+addl(list,n-1):list[n-1]):0;

// Wrapper for Rudolf Huttary's gear2D (optimised using symmetry)
module gear2D (
	number_of_teeth,
	circular_pitch,
	pressure_angle,
	depth_ratio,
    profile_shift,
	clearance){
    rotate([0,0,-90])seg(number_of_teeth)
        gear2D_(m = circular_pitch/PI, z = number_of_teeth, x = profile_shift, y = depth_ratio, w = pressure_angle, clearance = clearance);
}

// volume supported above gear for removing overhang
module gear2DS (
	number_of_teeth,
	circular_pitch,
	pressure_angle,
	depth_ratio,
    profile_shift,
	clearance,
    height){
    rotate([0,0,-90])seg(number_of_teeth)overhang(number_of_teeth,height)
        gear2D_(m = circular_pitch/PI, z = number_of_teeth, x = profile_shift, y = depth_ratio, w = pressure_angle, clearance = clearance);
}

// half-tooth overhang volume
module overhang(number_of_teeth,height){
    linear_extrude(layer_h+TT)children();
    translate([0,0,layer_h])intersection(){
        minkowski(){
            linear_extrude(layer_h)children();
            cylinder(r1=0,r2=height,h=height,$fn=6);
        }
        if(number_of_teeth>1)translate([AT,0,0]) // a little more overlap helps
            rotate([0,0,90-180/number_of_teeth])translate([-2*height,0,0])cube(4*height);
        if(number_of_teeth>1)translate([-AT,0,0])
            translate([0,-2*height,0])cube(4*height);
    }
}

module ring2D(
    radius,
    sun_teeth,
    planet_teeth,
	number_of_teeth,
	circular_pitch,
	pressure_angle,
	depth_ratio,
    profile_shift,
	clearance){
        rotate([0,0,-90])seg(number_of_teeth)
            Gear2D_(m = circular_pitch/PI, z = number_of_teeth, x = profile_shift, y = depth_ratio, w = pressure_angle, clearance = clearance, s=sun_teeth,p=planet_teeth,r=radius);
}

// volume supported above gear for removing overhang
module ring2DS(
    radius,
    sun_teeth,
    planet_teeth,
	number_of_teeth,
	circular_pitch,
	pressure_angle,
	depth_ratio,
    profile_shift,
	clearance,
    height){
    rotate([0,0,-90])seg(number_of_teeth)overhang(number_of_teeth,height)
        Gear2D_(m = circular_pitch/PI, z = number_of_teeth, x = profile_shift, y = depth_ratio, w = pressure_angle, clearance = clearance, s=sun_teeth,p=planet_teeth,r=radius);      
}


module sun2D(
    planet_teeth,
	number_of_teeth,
	circular_pitch,
	pressure_angle,
	depth_ratio,
    profile_shift,
	clearance){
        rotate([0,0,-90])seg(number_of_teeth)
            Sun2D_(m = circular_pitch/PI, z = number_of_teeth, x = profile_shift, y = depth_ratio, w = pressure_angle, clearance = clearance,p=planet_teeth);
}

// volume supported above gear for removing overhang
module sun2DS(
    planet_teeth,
	number_of_teeth,
	circular_pitch,
	pressure_angle,
	depth_ratio,
    profile_shift,
	clearance,
    height){
    rotate([0,0,-90])seg(number_of_teeth)overhang(number_of_teeth,height)
        Sun2D_(m = circular_pitch/PI, z = number_of_teeth, x = profile_shift, y = depth_ratio, w = pressure_angle, clearance = clearance,p=planet_teeth);
}


// Rotational and mirror symmetry
module seg(z=10){
    for(i=[0:360/z:359.9])rotate([0,0,i]){
        children();
        mirror([1,0,0])children();
    }
}

module gear2D_(m = 1, z = 10, x = 0, y = 0, w = 20, clearance = 0){
  	r_wk = m*z/2 + x; 
    U = m*z*PI; 
   	dy = m;  
  	r_fkc = r_wk + 2*dy;// *(1-clearance/2);  
    s = 360/iterations/z;
    difference(){
        intersection(){  // workpiece
            circle(r_fkc);
            translate([0,-r_fkc,0])square(2*r_fkc);
            if(z>1)translate([AT,0,0]) // a little more overlap helps
                rotate([0,0,90-180/z])translate([-r_fkc,0,0])square(2*r_fkc);
        }  
        for(i=[-(z>1?360:180)/z:s:(z>1?360:180)/z])
            rotate([0, 0, -i])translate([-i/360*U, 0, 0])
                Rack(m, z, x, y, w, clearance);  // Tool
    }
}

module Gear2D_(m = 1, z = 10, x = 0, y = 0, w = 20, clearance = 0, s = 5, p = 5, r = 20){
    offset=(s+p)*m/2;
    difference(){
        intersection(){
            circle(r);  // workpiece
            translate([0,-r,0])square(2*r);
            if(z>1)translate([AT,0,0]) // a little more overlap helps
                rotate([0,0,90-180/z])translate([-r,0,0])square(2*r);
        }
        circle(offset+m*(p/2-x-1)-clearance);
        for(i=[-iterations:iterations])
            rotate([0,0,i*360/z/iterations])translate([0,offset,0])
                rotate([0,0,-i*360/p/iterations])
                    gear2D_(m,p,-x,y,w,clearance); // Tool
    }
}

module Sun2D_(m = 1, z = 10, x = 0, y = 0, w = 20, clearance = 0, p = 5){
    r=(z+p)*m/2;
    difference(){
        intersection(){
            circle(m*z/2 + x + m); // fudged...
            translate([0,-r,0])square(2*r);
            if(z>1)translate([AT,0,0]) // a little more overlap helps
                rotate([0,0,90-180/z])translate([-r,0,0])square(2*r);
        }
        rotate([0,0,-180/z])
        for(i=[-iterations:iterations])
            rotate([0,0,i*360/z/iterations])translate([0,r,0])
                rotate([0,0,180+i*360/p/iterations])
                    gear2D_(m,p,-x,y,w,-clearance); // Tool
    }
}

module Rack(m = 2, z = 10, x = 0, y = 0, w = 20, clearance = 0){
    polygon(rack(m, z, x, y, w, clearance));
}

// We only need to cut half of one tooth, the rest is symmetry,
function rack(m = 2, z = 10, x = 0, y = 0, w = 20, clearance = 0, b = 0.5) = 
  let (dx = 2*tan(w))
  let (c = clearance/m)
  let (o = dx/2-PI/4)
  let (r = z/2 + x + 1)
  let(X=[-PI, -PI, b*PI-dx*(1+y)/2-c, b*PI-c, PI, PI])
  let(Y=[r+5, r-1+y-c, r-1+y-c, r-2-c, r-2-c, r+5])
  m*[for(j=[0:5]) [o+X[j], Y[j]]];
