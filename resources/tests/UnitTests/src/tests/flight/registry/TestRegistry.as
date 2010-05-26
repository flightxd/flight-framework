package tests.flight.registry
{
	import flash.display.Sprite;
	
	import flexunit.framework.Assert;
	import flexunit.framework.TestCase;
	
	import flight.utils.Registry;
	
	public class TestRegistry extends TestCase
	{
		public function TestRegistry()
		{
		}
		
		public function testRegisterGlobal():void
		{
			Registry.register("value", 1);
			Assert.assertEquals( Registry.lookup("value"), 1 );
			Assert.assertEquals( Registry.lookup("value", "someScope"), 1 );
		}
		
		public function testRegisterScope():void
		{
			Registry.register("value2", 2, "someScope");
			Assert.assertNull( Registry.lookup("value2") );
			Assert.assertEquals( Registry.lookup("value2", "someScope"), 2 );
		}
		
		public function testRegisterObjectScope():void
		{
			Registry.register("value3", 3, this);
			Assert.assertNull( Registry.lookup("value3") );
			Assert.assertNull( Registry.lookup("value3", this.toString()) );
			Assert.assertEquals( Registry.lookup("value3", this), 3 );
		}
		
		public function testRegisterDisplayList():void
		{
			// create a "display list" by linking a list of sprites in a parent-child chain
			var sprite:Sprite = new Sprite();
			var sprites:Array = [sprite];
			for(var i:int = 1; i < 20; i++)
			{
				sprite.addChild(new Sprite());
				sprite = sprite.getChildAt(0) as Sprite;
				sprites.push(sprite);
			}
			
			var parent:Sprite = sprites[2];
			Registry.register("value4", 4, parent);
			Assert.assertNull( Registry.lookup("value4") );
			// only looks upward through parents, and sprites[1] is a parent of sprites[2]
			Assert.assertNull( Registry.lookup("value4", sprites[1]) );
			Assert.assertEquals( Registry.lookup("value4", sprite), 4 );
		}
		
		public function testRegisterOwner():void
		{
			// Registry should traverse up through parent and owner both, on DisplayObject's or otherwise
			var object:Object = {};
			var objects:Array = [object];
			for(var i:int = 1; i < 20; i++)
			{
				object = {owner:object};
				objects.push(object);
			}
			
			var owner:Object = objects[2];
			Registry.register("value5", 5, owner);
			Assert.assertNull( Registry.lookup("value5") );
			// only looks upward through owners, and objects[1] is an owner of objects[2]
			Assert.assertNull( Registry.lookup("value5", objects[1]) );
			Assert.assertEquals( Registry.lookup("value5", object), 5 );
		}
		
		public function testSync():void
		{
			// syncing should keep an objects property bound to a particular registry value
			var endpoint:Object = {prop:null};
			Assert.assertNull( endpoint.prop );
			Registry.register("value6", 6);
			Registry.sync(endpoint, "prop", "value6");
			Assert.assertEquals( endpoint.prop, 6 );
			Registry.register("value6", 6.1);
			Assert.assertEquals( endpoint.prop, 6.1 );
			Registry.register("value6.5", 6.5);
			Registry.sync(endpoint, "prop", "value6.5");
			Assert.assertEquals( endpoint.prop, 6.5 );
			Registry.desync(endpoint, "prop");
			Registry.register("value6.5", 6.6);
			Assert.assertEquals( endpoint.prop, 6.5 );
		}
		
	}
}