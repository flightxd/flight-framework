package flexUnitTests.binding
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.System;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import flexunit.framework.Assert;
	
	import flight.binding.Bind;
	import flight.binding.Binding;
	
	import org.flexunit.asserts.*;
	import org.flexunit.async.Async;
	
	public class BindTest extends EventDispatcher
	{
		public var obj1:TestObject;
		public var obj2:TestObject;
		public var noMetaObj:NoMetaObject;
		public var dummyEvent:Event = new Event("_");
		
		[Before]
		public function setUp():void
		{
			obj1 = new TestObject();
			obj1.str = "TestStr1";
			obj1.num = 1;
			obj1.bool = true;
			obj1.obj = obj1.clone();
			
			obj2 = new TestObject();
			obj2.str = "TestStr2";
			obj2.num = 2;
			obj2.bool = false;
			obj2.obj = obj2.clone();
			
			noMetaObj = new NoMetaObject();
			noMetaObj.str = "TestStr";
			noMetaObj.num = 10;
			noMetaObj.bool = true;
			noMetaObj.obj = noMetaObj.clone();
		}
		
		[After]
		public function tearDown():void
		{
			obj1 = obj2 = null;
			noMetaObj = null;
		}
		
		
		[Test]
		public function testSimpleOneWay():void
		{
			Bind.addBinding(obj2, "str", obj1, "str");
			assertEquals("TestStr1", obj2.str);
			
			obj2.str = "noAffect";
			assertEquals("TestStr1", obj1.str);
			assertEquals("noAffect", obj2.str);
			
			obj1.str = "TestChange";
			assertEquals("TestChange", obj2.str);
		}
		
		[Test]
		public function testDeepOneWay():void
		{
			Bind.addBinding(obj2, "obj.str", obj1, "obj.str");
			assertEquals("TestStr1", obj2.obj.str);
			
			obj2.obj.str = "noAffect";
			assertEquals("TestStr1", obj1.obj.str);
			assertEquals("noAffect", obj2.obj.str);
			
			obj1.obj.str = "TestChange";
			assertEquals("TestChange", obj2.obj.str);
		}
		
		[Test]
		public function testSimpleTwoWay():void
		{
			Bind.addBinding(obj2, "str", obj1, "str", true);
			assertEquals("TestStr1", obj2.str);
			
			obj2.str = "TestChangeFrom2";
			assertEquals("TestChangeFrom2", obj1.str);
			assertEquals("TestChangeFrom2", obj2.str);
			
			obj1.str = "TestChangeFrom1";
			assertEquals("TestChangeFrom1", obj1.str);
			assertEquals("TestChangeFrom1", obj2.str);
		}
		
		[Test]
		public function testDeepTwoWay():void
		{
			Bind.addBinding(obj2, "obj.str", obj1, "obj.str", true);
			assertEquals("TestStr1", obj2.obj.str);
			
			obj2.obj.str = "TestChangeFrom2";
			assertEquals("TestChangeFrom2", obj1.obj.str);
			assertEquals("TestChangeFrom2", obj2.obj.str);
			
			obj1.obj.str = "TestChangeFrom1";
			assertEquals("TestChangeFrom1", obj2.obj.str);
		}
		
		[Test]
		public function testDeepScenarios():void
		{
			obj2.obj = null;
			Bind.addBinding(obj2, "obj.str", obj1, "obj.str");
			obj2.obj = obj2.clone();
			assertEquals("TestStr1", obj2.obj.str);
		}
		
		[Test]
		public function testDeepScenarios2():void
		{
			obj2.obj = null;
			Bind.addBinding(obj2, "obj.str", obj1, "obj.str", true);
			obj2.obj = obj2.clone();
			assertEquals("TestStr2", obj1.obj.str);
		}
		
		[Test]
		public function testStrToNumber():void
		{
			Bind.addBinding(obj2, "num", obj1, "str");
			obj1.str = "20";
			assertEquals("Number did not get set to correctly", 20, obj2.num);
		}
		
		[Test(async)]
		public function testListener():void
		{
			Bind.addListener(this, valueChange, obj1, "obj.str");
			
			assertEquals("Listener not called or called incorrectly", "TestStr1", newValue);
			
			obj1.obj.str = "TestChange";
			assertEquals("Listener not called or called incorrectly", "TestChange", newValue);
			
			obj1.obj = obj2;
			assertEquals("Listener not called or called incorrectly", "TestStr2", newValue);
			
			System.gc();
			
			var params:Object = {obj1: obj1, obj2: obj2};
			setTimeout(Async.asyncHandler(this, checkListenerValue, 500, params), 10, dummyEvent);
		}
		
		private function checkListenerValue(event:Event, params:Object):void
		{
			params.obj1.obj.str = "TestChange2";
			assertEquals("Listener dropped out of memory", "TestChange2", newValue);
		}
		
		protected var newValue:String;
		public function valueChange(value:String):void
		{
			newValue = value;
		}
		
		[Test]
		public function testIncorrectString():void
		{
			Bind.addBinding(obj2, "obj.str", obj1, "obj.str2");
			assertNull("Incorrect bindings did not fail gracefully with null", obj2.obj.str);
		}
		
		[Test(async)]
		public function testMemoryRelease():void
		{
			var dict:Dictionary = new Dictionary(true);
			var temp:TestObject = obj1.clone();
			dict[temp] = true;
			Bind.addBinding(temp, "str", obj1, "str");
			temp = obj1.clone();
			dict[temp] = true;
			Bind.addBinding(obj1, "str", temp, "str");
			
			System.gc(); // force collection after this process
			
			var params:Object = {dict: dict, msg: "Object was not removed from memory after there were no references to it"};
			setTimeout(Async.asyncHandler(this, checkEmptyDict, 500, params), 10, dummyEvent);
		}
		
		[Test(async)]
		public function testMemoryReleaseListener():void
		{
			var dict:Dictionary = new Dictionary(true);
			var temp:TestObject = obj1.clone();
			dict[temp] = true;
			
			newValue = "";
			Bind.addListener(this, valueChange, temp, "str");
			
			assertEquals("Listener not called or called incorrectly", "TestStr1", newValue);
			
			temp.str = "TestChange";
			assertEquals("Listener not called or called incorrectly", "TestChange", newValue);
			
			
			System.gc();
			
			var params:Object = {dict: dict, msg: "Object was not removed from memory after there were no references to it"};
			setTimeout(Async.asyncHandler(this, checkEmptyDict, 500, params), 10, dummyEvent);
		}
		
		[Test(async)]
		public function testMemoryReleaseEventListener():void
		{
			var dict:Dictionary = new Dictionary(true);
			var temp:TestObject = obj1.clone();
			temp.obj = temp.clone();
			dict[temp] = true;
			
			eventTriggered = 0;
			var binding:Binding = Bind.bindEventListener("customChange", onChange, temp, "obj");
			temp.obj.custom = "test";
			assertEquals("The event was not bound correctly or triggered.", 1, eventTriggered);
			temp.obj = new TestObject();
			temp.obj.custom = "test2";
			assertEquals("The event was not triggered when the new dispatcher dispatched.", 2, eventTriggered);
			
			System.gc();
			
			var params:Object = {dict: dict, msg: "Object was not removed from memory after there were no references to it"};
			setTimeout(Async.asyncHandler(this, checkEmptyDict, 500, params), 10, dummyEvent);
		}
		
		private function checkEmptyDict(event:Event, params:Object):void
		{
			for (var i:Object in params.dict) {}
			assertNull(params.msg, i);
		}
		
		[Test]
		public function testEventListener():void
		{
			var binding:Binding = Bind.bindEventListener("customChange", onChange, obj1, "obj");
			obj1.obj.custom = "test";
			assertEquals("The event was not bound correctly or triggered.", 1, eventTriggered);
			obj1.obj = new TestObject();
			obj1.obj.custom = "test2";
			assertEquals("The event was not triggered when the new dispatcher dispatched.", 2, eventTriggered);
		}
		
		private var eventTriggered:int;
		public function onChange(event:Event):void
		{
			eventTriggered++;
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
	
	public static function getBindingEvents(target:Object, property:String):Object
	{
		return Binding.getBindingEvents(target, property);
	}
	
	public static function clearCache():void
	{
		Binding.descCache = new Dictionary();
	}
}
