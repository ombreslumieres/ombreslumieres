abstract class Command
{
  private int _spray_can_index;
  
  public Command(int spray_can_index)
  {
    this._spray_can_index = spray_can_index;
  }
  
  public int get_spray_can_index()
  {
    return this._spray_can_index;
  }
  
  public abstract void apply(App app);
}


public class AddNodeCommand extends Command
{
    private float _x;
    private float _y;
    private float _size;
    
    public AddNodeCommand(int spray_can_index, float x, float y, float size)
    {
      super(spray_can_index);
      this._x = x;
      this._y = y;
      this._size = size;
    }
    
    public final void apply(App app)
    {
      app.apply_add_node(this.get_spray_can_index(), this._x, this._y); // TODO , this._size);
    }
}


public class NewStrokeCommand extends Command
{
    public NewStrokeCommand(int spray_can_index)
    {
      super(spray_can_index);
    }
    
    public final void apply(App app)
    {
      app.apply_new_stroke(this.get_spray_can_index());
    }
}


public class UndoCommand extends Command
{
    public UndoCommand(int spray_can_index)
    {
      super(spray_can_index);
    }
    
    public final void apply(App app)
    {
      println("Undo: todo");
      // TODO
    }
}


public class RedoCommand extends Command
{
    public RedoCommand(int spray_can_index)
    {
      super(spray_can_index);
    }
    
    public final void apply(App app)
    {
      // TODO
    }
}