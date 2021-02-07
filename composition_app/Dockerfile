FROM mcr.microsoft.com/dotnet/sdk:5.0
RUN apt-get update
COPY . /proj
RUN dotnet publish /proj -o /app

FROM mcr.microsoft.com/dotnet/runtime:5.0
RUN apt-get update
RUN apt-get install -y libgdiplus
WORKDIR /app
COPY --from=0 /app /app
ENTRYPOINT ["dotnet", "/app/composition_app.dll"]