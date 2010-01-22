package flexUnitTests.binding
{
	import flash.events.Event;
	import flash.system.System;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import flexunit.framework.Assert;
	
	import flight.binding.Binding;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;
	
	public class BindingTest
	{
		public var obj:TestObject;
		public var noMetaObj:NoMetaObject;
		public var dummyEvent:Event = new Event("_");
		
		[Before]
		public function setUp():void
		{
			obj = new TestObject();
			obj.str = "TestStr";
			obj.num = 10;
			obj.bool = true;
			obj.obj = obj.clone();
			
			noMetaObj = new NoMetaObject();
			noMetaObj.str = "TestStr";
			noMetaObj.num = 10;
			noMetaObj.bool = true;
			noMetaObj.obj = noMetaObj.clone();
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test]
		public function testDescribeBindings():void
		{
			var bindings:Object = IntrospectBinding.describeBindings(obj);
			assertTrue("Binding metadata doesn't exist for \"str\"", "str" in bindings);
			assertTrue("Binding metadata doesn't exist for \"custom\"", "custom" in bindings);
			
			assertEquals("More than one binding metadata exists for \"str\"", bindings.str.length, 1);
			assertEquals("More than one binding metadata exists for \"custom\"", bindings.custom.length, 1);
			
			assertEquals(bindings.str[0], "propertyChange");
			assertEquals(bindings.custom[0], "customChange");
			
			IntrospectBinding.clearCache();
			bindings = IntrospectBinding.describeBindings(noMetaObj);
			for (var i:String in bindings) {}
			assertNull("Binding metadata exists and shouldn't with no binding tags", i);
		}
		
		[Test]
		public function testGetBindingEvents():void
		{
			var events:Array = IntrospectBinding.getBindingEvents(obj, "str");
			assertEquals(events.length, 1);
			assertEquals(events[0], "propertyChange");
			
			events = IntrospectBinding.getBindingEvents(obj, "custom");
			assertEquals(events.length, 1);
			assertEquals(events[0], "customChange");
			
			events = IntrospectBinding.getBindingEvents(noMetaObj, "str");
			assertEquals(events.length, 1);
			assertEquals(events[0], "strChange");
		}
		
		[Test]
		public function testSimpleValue():void
		{
			var binding:Binding = new Binding(obj, "str");
			assertEquals(binding.value, "TestStr");
		}
		
		[Test]
		public function testSimpleValueUpdate():void
		{
			var binding:Binding = new Binding(obj, "str");
			assertEquals("TestStr", binding.value);
			
			obj.str = "Test2Str";
			assertEquals("Test2Str", binding.value);
		}
		
		[Test]
		public function testDeepValue():void
		{
			var binding:Binding = new Binding(obj, "obj.str");
			assertEquals("TestStr", binding.value);
		}
		
		[Test]
		public function testDeepValueUpdate():void
		{
			var binding:Binding = new Binding(obj, "obj.str");
			assertEquals("TestStr", binding.value);
			
			obj.obj.str = "Test2Str";
			assertEquals("Test2Str", binding.value);
		}
		
		[Ignore] // traces a warning each time. Don't want that in the output every time.
		[Test]
		public function testIncorrectString():void
		{
			var binding:Binding = new Binding(obj, "obj.str2");
			assertNull("Incorrect bindings did not fail gracefully with null", binding.value);
		}
		
		[Test]
		public function testStrToNumber():void
		{
			var binding:Binding = new Binding(obj, "num");
			binding.value = "20";
			assertEquals("Number did not get set to correctly", 20, obj.num);
		}
		
		[Test]
		public function testBind():void
		{
			var binding:Binding = new Binding(obj, "obj.str");
			binding.bind(noMetaObj, "str");
			binding.bind(noMetaObj.obj, "str");
			obj.obj.str = "TestChange";
			assertEquals("TestChange", noMetaObj.str);
			assertEquals("TestChange", noMetaObj.obj.str);
		}
		
		[Test]
		public function testBindingRelease():void
		{
			var binding:Binding = new Binding(obj, "obj.str");
			
			assertTrue("No listener for when the property \"obj\" changes.", obj.hasEventListener("propertyChange"));
			assertTrue("No listener for when the property \"str\" changes.", obj.obj.hasEventListener("propertyChange"));
			
			binding.release();
			
			assertFalse("Didn't release the listener on property \"obj\" change.", obj.hasEventListener("propertyChange"));
			assertFalse("Didn't release the deeper listener on property \"str\" change.", obj.obj.hasEventListener("propertyChange"));
			
			binding = Binding.getBinding(obj, "obj.str");
			
			assertTrue(obj.hasEventListener("propertyChange"));
			assertTrue(obj.obj.hasEventListener("propertyChange"));
			
			Binding.release(obj);
			
			assertFalse("Didn't release all bindings from static call.", obj.hasEventListener("propertyChange"));
			assertFalse("Didn't release all deep bindings from static call.", obj.obj.hasEventListener("propertyChange"));
		}
		
		[Test(async)]
		public function testMemoryReleaseAfterRelease():void
		{
			var dict:Dictionary = new Dictionary(true);
			var temp:TestObject = obj.clone();
			dict[temp] = true;
			var binding:Binding = Binding.getBinding(temp, "str");
			binding.bind(obj, "str");
			Binding.release(temp);
			
			System.gc(); // force collection after this process
			
			var params:Object = {dict: dict, msg: "Object was not removed from memory after being property released and with no references"};
			setTimeout(Async.asyncHandler(this, checkEmptyDict, 500, params), 10, dummyEvent);
		}
		
		[Test(async)]
		public function testMemoryRelease():void
		{
			var dict:Dictionary = new Dictionary(true);
			var temp:TestObject = obj.clone();
			dict[temp] = true;
			var binding:Binding = Binding.getBinding(temp, "str");
			binding.bind(obj, "str");
			
			System.gc(); // force collection after this process
			
			var params:Object = {dict: dict, msg: "Object was not removed from memory after there were no references to it"};
			setTimeout(Async.asyncHandler(this, checkEmptyDict, 500, params), 10, dummyEvent);
		}
		
		[Test]
		public function testReset():void
		{
			assertFalse("Should not start with \"propertyChange\" listener", obj.hasEventListener("propertyChange"));
			var binding:Binding = new Binding(obj, "str");
			assertTrue("Binding did not add listener for \"propertyChange\" event.", obj.hasEventListener("propertyChange"));
			
			assertFalse("Binding should not be listening for \"customChange\" event yet.", obj.hasEventListener("customChange"));
			binding.reset(obj, "custom");
			assertFalse("Binding did not remove listener for \"propertyChange\" event.", obj.hasEventListener("propertyChange"));
			assertTrue("Binding did not add listener for \"customChange\" event.", obj.hasEventListener("customChange"));
		}
		
		private function checkEmptyDict(event:Event, params:Object):void
		{
			for (var i:Object in params.dict) {}
			assertNull(params.msg, i);
		}
	}
}

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;

import flight.binding.Binding;

[Bindable]
internal class TestObject extends EventDispatcher
{
	public var str:String;
	public var num:Number;
	public var bool:Boolean;
	public var obj:TestObject;
	
	private var _custom:String;
	[Bindable("customChange")]
	public function get custom():String {return _custom;}
	public function set custom(value:String):void {
		if (_custom == value) return;
		_custom = value;
		dispatchEvent(new Event("customChange"));
	}
	
	public function clone():TestObject
	{
		var obj:TestObject = new TestObject();
		obj.str = str;
		obj.num = num;
		obj.bool = bool;
		obj.custom = custom;
		return obj;
	}
}

internal class NoMetaObject extends EventDispatcher
{
	private var _str:String;
	public function get str():String {return _str;}
	public function set str(value:String):void {
		if (_str == value) return;
		_str = value;
		dispatchEvent(new Event("strChange"));
	}
	
	private var _num:Number;
	public function get num():Number {return _num;}
	public function set num(value:Number):void {
		if (_num == value) return;
		_num = value;
		dispatchEvent(new Event("numChange"));
	}
	
	private var _bool:Boolean;
	public function get bool():Boolean {return _bool;}
	public function set bool(value:Boolean):void {
		if (_bool == value) return;
		_bool = value;
		dispatchEvent(new Event("boolChange"));
	}
	
	private var _obj:NoMetaObject;
	public function get obj():NoMetaObject {return _obj;}
	public function set obj(value:NoMetaObject):void {
		if (_obj == value) return;
		_obj = value;
		dispatchEvent(new Event("objChange"));
	}
	
	public function clone():NoMetaObject
	{
		var obj:NoMetaObject = new NoMetaObject();
		obj.str = str;
		obj.num = num;
		obj.bool = bool;
		return obj;
	}
}

internal class IntrospectBinding extends Binding
{
	public static function describeBindings(value:Object):Object
	{
		return Binding.describeBindings(value);
	}
	
	public static function getBindingEvents(target:Object, property:String):Array
	{
		return Binding.getBindingEvents(target, property);
	}
	
	public static function clearCache():void
	{
		Binding.descCache = new Dictionary();
	}
}


