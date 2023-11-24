using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Noble.Service.To.Legend.RNNobleServiceToLegend
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNNobleServiceToLegendModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNNobleServiceToLegendModule"/>.
        /// </summary>
        internal RNNobleServiceToLegendModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNNobleServiceToLegend";
            }
        }
    }
}
