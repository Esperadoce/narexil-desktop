pragma Singleton
import Quickshell

Singleton {
    id: root
    property bool shown: false
    function toggle(): void { shown = !shown }
    function show():   void { shown = true   }
    function hide():   void { shown = false  }
}
