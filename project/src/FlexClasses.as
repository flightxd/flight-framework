////////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2009 Tyler Wright, Robert Taylor, Jacob Wright
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

package
{
	/**
	 * @private
	 * This class is used to link additional classes into flight-framework.swc
	 * beyond those that are found by dependecy analysis starting from the
	 * classes specified in manifest.xml. For example, compiler-required
	 * references to Flex classes for use of an MXML workflow and the [Bindable]
	 * metadata tag in AS3-only projects - many of these classes are never
	 * actually used, not even in the auto-generated code.
	 */
	internal class FlexClasses
	{
		// binding references for use of the [Bindable] metadata tag
		import mx.binding.BindingManager;				BindingManager;
		import mx.core.IPropertyChangeNotifier;			IPropertyChangeNotifier;
		import mx.utils.ObjectProxy;					ObjectProxy;
		import mx.utils.UIDUtil;						UIDUtil;
		
		// mx core references for use of MXML
		import mx.styles.StyleManager;					StyleManager;
		import mx.core.ClassFactory;					ClassFactory;
		import mx.core.DeferredInstanceFromClass;		DeferredInstanceFromClass;
		import mx.core.DeferredInstanceFromFunction;	DeferredInstanceFromFunction;
		
		// binding references for use of the curly-brace binding in MXML
		import mx.binding.IWatcherSetupUtil;			IWatcherSetupUtil;
		// Required class for Flash Buider 4 binding in AS3 projects
		//import mx.binding.IWatcherSetupUtil2;			IWatcherSetupUtil2;
		import mx.binding.ArrayElementWatcher;			ArrayElementWatcher;
		import mx.binding.FunctionReturnWatcher;		FunctionReturnWatcher;
		import mx.binding.PropertyWatcher;				PropertyWatcher;
		import mx.binding.RepeaterComponentWatcher;		RepeaterComponentWatcher;
		import mx.binding.RepeaterItemWatcher;			RepeaterItemWatcher;
		import mx.binding.StaticPropertyWatcher;		StaticPropertyWatcher;
		import mx.binding.XMLWatcher;					XMLWatcher;
	}

}
