class MGActorStateTrigger extends Trigger;

struct StateActor
{
    var() bool bMustBeTouching;
    var() Name StateToSendTo;
    var() Actor StateActor;
};

var() Array<StateActor> StateActors;

event Activate(Actor Other, Pawn EventInstigator)
{
    local Actor temp_touching_actor;
    local bool b_touching;
    local int i;


    Super.Activate(Other, EventInstigator);

    for (i = 0; i < StateActors.Length; i++)
    {
           b_touching = false;

        if (StateActors[i].StateActor != None)
        {
            // MaxG: Must be touching the trigger to send to state.
            if (StateActors[i].bMustBeTouching)
            {
                ForEach TouchingActors(Class'Actor', temp_touching_actor)
                {
                    if (temp_touching_actor == StateActors[i].StateActor)
                    {
                        b_touching = true;
                        break;
                    }
                }

                if (b_touching)
                {
                    StateActors[i].StateActor.GoToState(StateActors[i].StateToSendTo);
                }
                else
                {
                    CM("[" $ Name $ "]::Activate ==> [" $ StateActors[i].StateActor.Name $ "] is not touching; state unchanged.");
                }
            }
            else
            {
                StateActors[i].StateActor.GoToState(StateActors[i].StateToSendTo);
            }
        }
        else
        {
            CM("[" $ Name $ "]::Activate ==> StateActor is none.");
        }
    }
}

defaultproperties
{
    bDoActionWhenTriggered=True
    TriggerType=TT_ClassProximity
    bCollideActors=False
}