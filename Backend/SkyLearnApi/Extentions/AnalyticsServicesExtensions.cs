using SkyLearnApi.Configuration;
using SkyLearnApi.Services.Implementations;
using SkyLearnApi.Services.Interfaces;

namespace SkyLearnApi.Extentions
{
    public static class AnalyticsServicesExtensions
    {
        public static IServiceCollection AddAnalyticsServices(this IServiceCollection services, IConfiguration configuration)
        {
            services.Configure<AnalyticsOptions>(configuration.GetSection(AnalyticsOptions.SectionName));
            services.AddSingleton<IAnalyticsCsvReader, AnalyticsCsvReader>();
            return services;
        }
    }
}
