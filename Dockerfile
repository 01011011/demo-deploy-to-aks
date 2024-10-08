FROM mcr.microsoft.com/dotnet/sdk:8.0 AS builder
WORKDIR /app

# caches restore result by copying csproj file separately
COPY sampleapp/*.csproj .
RUN dotnet restore

COPY . .
RUN dotnet publish sampleapp.csproj --output /app/ --configuration Release --no-restore
RUN sed -n 's:.*<AssemblyName>\(.*\)</AssemblyName>.*:\1:p' *.csproj > __assemblyname
RUN if [ ! -s __assemblyname ]; then filename=$(ls *.csproj); echo ${filename%.*} > __assemblyname; fi

# Stage 2
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=builder /app .

ENV PORT 80
EXPOSE 80

ENTRYPOINT dotnet $(cat /app/__assemblyname).dll --urls "http://*:80"
