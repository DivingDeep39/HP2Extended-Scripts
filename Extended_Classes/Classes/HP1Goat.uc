//=============================================================================
// HP1Goat.
//=============================================================================
class HP1Goat expands HChar;

	var rotator rotval;
	var vector newloc;
	var rotator newrot;
	var float goatstuff;

auto state pause
{





	begin:
		setPhysics(PHYS_walking);

		while (true)
		{	
			loopanim('idle');
			sleep(1+frand()*3);	
			goatstuff=frand();

			if(goatstuff > 0.5)
			{			
				loopanim('lookaround');
				sleep(2);
				finishanim();
			}

			if(goatstuff < 0.5)
			{			
				loopanim('graze');
				sleep(1+frand()*5);
				playanim('lookup');
				finishanim();
			}
		}

}

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'Extended_Meshes.skGoat'
}
