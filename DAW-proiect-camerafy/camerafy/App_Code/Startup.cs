using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(camerafy.Startup))]
namespace camerafy
{
    public partial class Startup {
        public void Configuration(IAppBuilder app) {
            ConfigureAuth(app);
        }
    }
}
