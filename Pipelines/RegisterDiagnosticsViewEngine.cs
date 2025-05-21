using System.Web;
using System.Web.Mvc;

// This tells ASP.NET to run Register() *before* Application_Start
[assembly: PreApplicationStartMethod(
    typeof(MyCompany.Feature.RenderDecorator.RegisterDiagnosticsViewEngine),
    "Initialize")]

namespace MyCompany.Feature.RenderDecorator
{
    public static class RegisterDiagnosticsViewEngine
    {
        public static void Initialize()
        {
            // Insert ours at index 0 so it wins every FindView/CreateView call
            ViewEngines.Engines.Insert(0, new DiagnosticsRazorViewEngine());
        }
    }
}
