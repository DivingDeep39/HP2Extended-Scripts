//================================================================================
// SpiderDead.
//================================================================================

class SpiderDead extends SpiderSmall;

function PlayerCutCapture()
{
}

function PlayerCutRelease()
{
}

state StartPatrolling
{
begin:
  LoopAnim('Walk',1.20);
  GotoState('patrol');
}

defaultproperties
{
    GroundSpeed=75.00

    MenuName="SpiderDead"

}
