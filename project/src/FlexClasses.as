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
	import mx.binding.BindingManager;
	import mx.core.ClassFactory;
	import mx.core.DeferredInstanceFromClass;
	import mx.core.DeferredInstanceFromFunction;
	import mx.core.IPropertyChangeNotifier;
	import mx.styles.StyleManager;
	import mx.utils.ObjectProxy;
	import mx.utils.UIDUtil;
	
	import mx.binding.IWatcherSetupUtil;
	import mx.binding.IWatcherSetupUtil2;
	import mx.binding.ArrayElementWatcher;
	import mx.binding.FunctionReturnWatcher;
	import mx.binding.PropertyWatcher;
	import mx.binding.RepeaterComponentWatcher;
	import mx.binding.RepeaterItemWatcher;
	import mx.binding.StaticPropertyWatcher;
	import mx.binding.XMLWatcher;
		
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
		BindingManager;
		IPropertyChangeNotifier;
		ObjectProxy;
		UIDUtil;
		
		// mx core references for use of MXML
		StyleManager;
		ClassFactory;
		DeferredInstanceFromClass;
		DeferredInstanceFromFunction;
		
		// binding references for use of the curly-brace binding in MXML
		IWatcherSetupUtil;
		IWatcherSetupUtil2;
		ArrayElementWatcher;
		FunctionReturnWatcher;
		PropertyWatcher;
		RepeaterComponentWatcher;
		RepeaterItemWatcher;
		StaticPropertyWatcher;
		XMLWatcher;
	}

}
