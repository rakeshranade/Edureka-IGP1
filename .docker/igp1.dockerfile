# Save this file as .docker/igp1.dockerfile and build with:
# docker build -f .docker/igp1.dockerfile -t myblazorapp --build-arg PROJECT=src/MyBlazorApp/MyBlazorApp.csproj .

ARG DOTNET_VERSION=8.0
ARG PROJECT=src/MyBlazorApp/MyBlazorApp.csproj
ARG CONFIG=Release

# Stage 1 - build
FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_VERSION} AS build
WORKDIR /src

# Copy solution and project files for restore (keeps docker cache efficiency)
COPY . .
RUN dotnet restore "${PROJECT}"

# Build and publish
RUN dotnet publish "${PROJECT}" -c ${CONFIG} -o /app/publish --no-restore -p:PublishTrimmed=true

# Stage 2 - runtime
FROM mcr.microsoft.com/dotnet/aspnet:${DOTNET_VERSION} AS runtime
WORKDIR /app

ENV ASPNETCORE_URLS=http://+:8086
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true

# Copy published app from build stage
COPY --from=build /app/publish .

# Create a non-root user for better security (works on Debian-based images)
RUN addgroup --system app && adduser --system --ingroup app app
USER app

EXPOSE 8086
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8086/ || exit 1

ENTRYPOINT ["dotnet", "MyBlazorApp.dll"]