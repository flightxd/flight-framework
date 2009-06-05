package photoedit.editor
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import photoedit.editor.tools.Tool;
	
	[Bindable]
	public class Editor extends EventDispatcher
	{
		public var document:EditorDocument;
		public var documents:Dictionary;
		protected var tools:Array;									// associative array of tools by their tool id
		protected var activeTools:Array;							// list of all tools that are currently in use
		
		public function Editor():void
		{
			documents = new Dictionary(true);
			tools = [];
			activeTools = [];
		}
		
		/**
		 * Selects the list of DisplayObject's.
		 */
		public function select(displayObjects:Array):void
		{
			var selection:Array = [];								// create a new selection array to replace document's selection
			for(var i:uint = 0; i < displayObjects.length; i++)
			{
				var display:DisplayObject = displayObjects[i] as DisplayObject;
				// only add each object once, and only if it's a workArea child
				if(display != null && isSelectableChild(display) && selection.indexOf(display) == -1)
					selection.push(display);
			}
			document.selection = selection;
		}
		
		/**
		 * Allows Editor to restrict the types of displays that may be edited. This method is often overridden.
		 */
		public function isSelectableChild(display:DisplayObject):Boolean
		{
			return Boolean(display.parent == document.workArea && display != document.toolArea);
		}
		
		public function registerTool(id:String, tool:Tool):Tool
		{
			unregisterTool(id);
			tools[id] = tool;
			tool.editor = this;
			return tool;
		}
		
		// unregister tool by Tool or id (string)
		public function unregisterTool(id:String):Tool
		{
			var tool:Tool = tools[id] as Tool;
			if(tool == null)
				return null;
			
			deactivateTool(id);
			delete tools[id];
			tool.editor = null;
			return tool;
		}
		
		/**
		 * Activates Tool for use, calling Tool.activate and adding tool to Editors activeTools list. Tools must
		 * be activated through this method. Multiple tools may be active simultaneously.
		 */
		public function activateTool(id:String):Tool
		{
			var tool:Tool = tools[id] as Tool;
			if(tool == null || activeTools.indexOf(tool) != -1)		// if tool is in the list then it's already been activated
				return null;
			
			tool.activate();
			activeTools.push(tool);
			return tool;
		}
		
		/**
		 * Deactivates Tool by calling Tool.deactivate and removing tool from Editors activeTools list. Tools must
		 * be deactivated through this method.
		 */
		public function deactivateTool(id:String):Tool
		{
			var tool:Tool = tools[id] as Tool;
			if(tool == null || activeTools.indexOf(tool) == -1)		// if tool isn't in the list then it hasn't been activated
				return null;
			
			tool.deactivate();
			activeTools.splice(activeTools.indexOf(tool), 1);
			return tool;
		}
		
		public function deactivateAllTools():void
		{
			for(var i:uint = 0; i < activeTools.length; i++)
			{
				var tool:Tool = Tool(activeTools[i]);
				tool.deactivate();
			}
			activeTools = [];
		}
		
		
	}
}
