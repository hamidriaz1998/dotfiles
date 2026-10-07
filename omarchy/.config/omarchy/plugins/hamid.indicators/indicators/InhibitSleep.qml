import QtQuick
import qs.Ui

BarIndicator {
  id: root

  // State lives on the widget root (indicatorHost): this QML is instantiated
  // once per block (inactive + active) and must not own the Process itself.
  active: indicatorHost ? indicatorHost.inhibitSleepActive === true : false
  activeText: "󰒲"
  inactiveText: "󰒲"
  activeTooltipText: "Lid / Sleep / Idle inhibited"
  inactiveTooltipText: "Inhibit sleep"

  onPressed: function() {
    if (root.indicatorHost && root.indicatorHost.toggleInhibitSleep)
      root.indicatorHost.toggleInhibitSleep()
  }
}
