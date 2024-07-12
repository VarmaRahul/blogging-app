FROM python

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app
COPY blogging-app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY ./blogging-app .

EXPOSE 8000
ENTRYPOINT ["python", "manage.py"]
CMD ["runserver", "0.0.0.0:8000"]
