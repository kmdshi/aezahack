//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <file_selector_windows/file_selector_windows.h>
#include <ios_color_picker/ios_color_picker_plugin_c_api.h>
#include <pdfx/pdfx_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FileSelectorWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileSelectorWindows"));
  IosColorPickerPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("IosColorPickerPluginCApi"));
  PdfxPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PdfxPlugin"));
}
