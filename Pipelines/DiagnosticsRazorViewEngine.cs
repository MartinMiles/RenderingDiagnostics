// /Feature/RenderDecorator/DiagnosticsRazorViewEngine.cs
using System;
using System.IO;
using System.Web.Mvc;
using Sitecore.Mvc.Presentation;

namespace MyCompany.Feature.RenderDecorator
{
    public class DiagnosticsRazorViewEngine : RazorViewEngine
    {
        // All the default locations stay the same—just intercept CreateView/CreatePartialView
        protected override IView CreateView(ControllerContext controllerContext, string viewPath, string masterPath)
        {
            var inner = base.CreateView(controllerContext, viewPath, masterPath);
            return new DiagnosticsView(inner, viewPath);
        }

        protected override IView CreatePartialView(ControllerContext controllerContext, string partialPath)
        {
            var inner = base.CreatePartialView(controllerContext, partialPath);
            return new DiagnosticsView(inner, partialPath);
        }
    }

    // This wrapper will writes JSON comment before and after the real view renders
    public class DiagnosticsView : IView
    {
        private readonly IView _inner;
        private readonly string _viewPath;

        public DiagnosticsView(IView inner, string viewPath)
        {
            _inner = inner;
            _viewPath = viewPath;
        }

        public void Render(ViewContext viewContext, TextWriter writer)
        {
            // Grab the Sitecore rendering context
            var rendering = RenderingContext.Current?.Rendering;
            var name = rendering?.RenderingItem?.Name ?? "unknown";
            var uid = rendering?.UniqueId.ToString() ?? Guid.Empty.ToString();

            // JSON payload
            var json = $"{{ name: \"{name}\", uid: \"{uid}\", path: \"{_viewPath}\" }}";

            // Emit start marker
            writer.Write($"\n<!-- start-component='{json}' -->\n");

            // Delegate to the real RazorView
            _inner.Render(viewContext, writer);

            // Emit end marker
            writer.Write($"\n<!-- end-component='{json}' -->\n");
        }
    }
}
