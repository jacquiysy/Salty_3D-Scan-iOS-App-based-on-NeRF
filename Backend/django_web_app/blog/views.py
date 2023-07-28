from django.shortcuts import render, get_object_or_404
from django.http import HttpResponse
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin
from django.contrib.auth.models import User
from django.views.generic import (
    ListView,
    DetailView,
    CreateView,
    UpdateView,
    DeleteView
)
from .models import Post
import operator
from django.urls import reverse_lazy
from django.contrib.staticfiles.views import serve

from django.db.models import Q
from django.http import JsonResponse

def home(request):
    context = {
        'posts': Post.objects.all()
    }
    return render(request, 'blog/home.html', context)

def search(request):
    template='blog/home.html'

    query=request.GET.get('q')

    result=Post.objects.filter(Q(title__icontains=query) | Q(author__username__icontains=query) | Q(content__icontains=query))
    paginate_by=2
    context={ 'posts':result }
    return render(request,template,context)
   


def getfile(request):
   return serve(request, 'File')



def post_title(request, pk):
    post = Post.objects.get(pk=pk)
    return HttpResponse(post.title)

def post_content(request, pk):
    post = Post.objects.get(pk=pk)
    return HttpResponse(post.content)

def post_file(request, pk):
    post = Post.objects.get(pk=pk)
    response = HttpResponse(post.file, content_type='application/octet-stream')
    response['Content-Disposition'] = f'attachment; filename="{post.file.name}"'
    return response

class PostListView(ListView):
    model = Post
    template_name = 'blog/home.html'  # <app>/<model>_<viewtype>.html
    context_object_name = 'posts'
    ordering = ['-date_posted']
    paginate_by = 2


class UserPostListView(ListView):
    model = Post
    template_name = 'blog/user_posts.html'  # <app>/<model>_<viewtype>.html
    context_object_name = 'posts'
    paginate_by = 2

    def get_queryset(self):
        user = get_object_or_404(User, username=self.kwargs.get('username'))
        return Post.objects.filter(author=user).order_by('-date_posted')


class PostDetailView(DetailView):
    model = Post
    template_name = 'blog/post_detail.html'


class PostCreateView(CreateView):
    model = Post
    template_name = 'blog/post_form.html'
    fields = ['title', 'content', 'file']

    

    def form_valid(self, form):
        if self.request.user.is_authenticated:
            form.instance.author = self.request.user
        else:
            # Handle the case where there is no logged-in user
            default_user = User.objects.get(username='root')
            form.instance.author = default_user
        return super().form_valid(form)
        

import json
from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
from .models import Post

@csrf_exempt
def create_post(request):
    if request.method != 'POST':
        return HttpResponse(status=400)

    # Load JSON data from the request body
    data = json.loads(request.body)
    title = data.get('title')
    content = data.get('content')
    file = request.FILES.get('file')

    # Create a new post
    post = Post.objects.create(title=title, content=content, file=file)

    # Return a JSON response
    response_data = {
        'id': post.id,
        'title': post.title,
        'content': post.content,
        'file': post.file.url if post.file else None
    }
    return JsonResponse(response_data)



class PostUpdateView(LoginRequiredMixin, UserPassesTestMixin, UpdateView):
    model = Post
    template_name = 'blog/post_form.html'
    fields = ['title', 'content', 'file']

    def form_valid(self, form):
        form.instance.author = self.request.user
        return super().form_valid(form)

    def test_func(self):
        post = self.get_object()
        if self.request.user == post.author:
            return True
        return False


class PostDeleteView(LoginRequiredMixin, UserPassesTestMixin, DeleteView):
    model = Post
    success_url = '/'
    template_name = 'blog/post_confirm_delete.html'

    def test_func(self):
        post = self.get_object()
        if self.request.user == post.author:
            return True
        return False


def about(request):
    return render(request, 'blog/about.html', {'title': 'About'})
