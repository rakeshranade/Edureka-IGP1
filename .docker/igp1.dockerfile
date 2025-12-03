ARG DOTNET_VERSION=8.0
ARG PROJECT=./src/Edureka-igp1/Edureka-igp1.csproj
ARG CONFIG=Release

# Stage 1 - build
FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_VERSION} AS build
WORKDIR /src
ENV ASPNETCORE_URLS=http://+:5000

COPY . .
RUN dotnet restore ./src/Edureka-igp1/Edureka-igp1.csproj
RUN dotnet build --runtime linux-x64 -c Debug -o /app/debug ./src/Edureka-igp1/Edureka-igp1.csproj
RUN chmod +x /app/debug/Edureka-igp1.dll
ENTRYPOINT ["dotnet", "/app/debug/Edureka-igp1.dll"]