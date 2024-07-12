from django.shortcuts import render, redirect
from django.contrib import messages
 
# import todo form and models
 
from .forms import UserForm

# Create your views here.
def index(request):
    return render(request, 'todoapp/todo_index.html')
