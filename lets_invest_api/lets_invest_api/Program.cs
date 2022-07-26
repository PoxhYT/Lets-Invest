global using lets_invest_api.Data;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
builder.Services.AddDbContext<Database>(options => {
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
    options.UseQueryTrackingBehavior(QueryTrackingBehavior.NoTracking);
});
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

using(var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<Database>();
    await db.Database.EnsureCreatedAsync();
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Enable cors
app.Use((httpContext, next) =>
{
    httpContext.Response.Headers.Add("Access-Control-Allow-Origin", "*");
    httpContext.Response.Headers.Add("Access-Control-Allow-Headers", "*");
    httpContext.Response.Headers.Add("Access-Control-Allow-Methods", "*");
            
    if (httpContext.Request.Method != "OPTIONS")
        return next();
            
    httpContext.Response.StatusCode = 204;
    return Task.CompletedTask;
});

app.UseAuthorization();

app.MapControllers();

app.Run();
