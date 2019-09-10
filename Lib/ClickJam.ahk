#Include <JSON>
#NoEnv

class ClickJam extends JSON
{
  max_delay
  {
    get {
      return this.delay_time + this.rand_delay
    }
  }
}
